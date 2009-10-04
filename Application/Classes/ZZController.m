//
//  DocumentController.m
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "ZZController.h"

@interface ZZController (Private)
- (void)_loadPlugins;
- (ZZConnection *)_connectionForRemote:(id)remote;
- (void)_addConnectionWithRemote:(id)remote;
- (void)_removeConnectionWithRemote:(id)remote;
@end


@implementation ZZController

#pragma mark -
#pragma mark Initialization & deallocation

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:3456] forKey:@"LPServerPort"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"ZZCheckForUpdatesOnStartup"];
	[dict setObject:[NSDate date] forKey:@"FRFeedbackReporter.lastCrashCheckDate"];
	[dict setObject:[[[NSBundle mainBundle] infoDictionary] 
		objectForKey:@"SUFeedURL"] forKey:@"SUFeedURL"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (id)init
{
	if (self = [super init])
	{
		[[FRFeedbackReporter sharedReporter] reportIfCrash];
		// start server
		m_connectedClients = [[NSMutableArray alloc] init];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		m_gateway = [[AMFDuplexGateway alloc] init];
		m_gateway.delegate = self;
		[m_gateway registerService:[[[ZZCoreService alloc] initWithDelegate:self] autorelease] 
			withName:@"CoreService"];
		m_prefsWindowController = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[m_connectedClients release];
	[super dealloc];
}

- (void)awakeFromNib
{
	m_windowController = [[ZZWindowController alloc] initWithWindowNibName:@"MainWindow" 
		delegate:self];
	m_plugInControllers = [[NSMutableArray alloc] init];
	[self _loadPlugins];
	
	NSError *error = nil;
	uint16_t port = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		valueForKey:@"LPServerPort"] shortValue];
	port = 3456;
	if (![m_socket acceptOnPort:port error:&error])
		NSLog(@"Could not start server on port %d", port);
	
	// start AMF server
	error = nil;
	[m_gateway startOnPort:(port + 1) error:&error];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	BOOL checkForUpdatesOnStartup = [[[[NSUserDefaultsController sharedUserDefaultsController]
		values] valueForKey:@"ZZCheckForUpdatesOnStartup"] boolValue];
	if (checkForUpdatesOnStartup)
		[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}

- (void)showTrazzleWindow:(id)sender
{
	[m_windowController showWindow:self];
}

- (IBAction)showPreferences:(id)sender
{
	if (!m_prefsWindowController)
	{
		NSWindow *window = [[NSWindow alloc] initWithContentRect:(NSRect){0, 0, 100, 100} 
			styleMask:(NSTitledWindowMask | NSClosableWindowMask) 
			backing:NSBackingStoreBuffered defer:YES];
		
		m_prefsWindowController = [[AAPreferencesWindowController alloc] initWithWindow:window];
		m_prefsWindowController.toolbarIdentifier = @"ZZPreferencesToolbar";
		m_prefsWindowController.windowAutosaveName = @"ZZPreferencesWindowOrigin";
		
		for (NSObject<TrazzlePlugIn> *plugin in m_loadedPlugins)
		{
			if ([plugin respondsToSelector:@selector(prefPane:icon:)])
			{
				NSViewController *viewController = nil;
				NSImage *icon = nil;
				[plugin prefPane:&viewController icon:&icon];
				[m_prefsWindowController addPrefPaneWithController:viewController icon:icon];
			}
		}
		ZZUpdatePreferencesViewController *updatePrefsController = 
			[[ZZUpdatePreferencesViewController alloc] initWithNibName:@"UpdatePreferences" 
				bundle:nil];
		[m_prefsWindowController addPrefPaneWithController:updatePrefsController 
			icon:[NSImage imageNamed:@"reload.tiff"]];
		
		[window release];
	}
	[m_prefsWindowController showWindow:self];
}

- (IBAction)reportFeedback:(id)sender
{
	[[FRFeedbackReporter sharedReporter] reportFeedback];
}



#pragma mark -
#pragma mark Private methods

- (void)_loadPlugins
{
	m_loadedPlugins = [[NSMutableArray alloc] init];
	NSString *pluginsPath = [[NSBundle mainBundle] builtInPlugInsPath];
	NSArray *plugins = [[NSFileManager defaultManager] directoryContentsAtPath:pluginsPath];

	for (NSString *path in plugins)
	{
		if (![[path pathExtension] isEqualToString:@"trazzlePlugin"])
		{
			continue;
		}
		
		NSBundle *pluginBundle = [NSBundle bundleWithPath:[pluginsPath 
			stringByAppendingPathComponent:path]];
		NSError *error = nil;
		if (![pluginBundle loadAndReturnError:&error])
		{
			NSLog(@"Error loading plugin: %@", error);
			continue;
		}
		
		Class prinClass = [pluginBundle principalClass];
		if (prinClass && class_conformsToProtocol(prinClass, @protocol(TrazzlePlugIn)))
		{
			PlugInController *plugInController = [[PlugInController alloc] 
				initWithPlugInBundle:pluginBundle windowController:m_windowController 
					gateway:m_gateway legacyConnection:m_socket connectedClients:m_connectedClients];
			[m_plugInControllers addObject:plugInController];
			
			NSObject <TrazzlePlugIn> *plugin = [[prinClass alloc] 
				initWithPlugInController:plugInController];
			[m_loadedPlugins addObject:plugin];
			[plugin release];
			[plugInController release];
		}
	}
}

- (ZZConnection *)_connectionForRemote:(id)remote
{
	for (ZZConnection *conn in m_connectedClients)
		if (conn.remote == remote)
			return conn;
	return nil;
}

- (void)_addConnectionWithRemote:(id)remote
{
	ZZConnection *client = [[ZZConnection alloc] initWithRemote:remote delegate:self];
	[m_connectedClients addObject:client];
	for (NSObject<TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(trazzleDidOpenConnection:)])
			objc_msgSend(plugin, @selector(trazzleDidOpenConnection:), client);
	}
	[client release];
}

- (void)_removeConnectionWithRemote:(id)remote
{
	ZZConnection *conn = [self _connectionForRemote:remote];
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(trazzleDidCloseConnection:)])
			objc_msgSend(plugin, @selector(trazzleDidCloseConnection:), conn);
	}
	[m_connectedClients removeObject:conn];
}



#pragma mark -
#pragma mark ZZWindowController delegate methods

- (void)windowController:(ZZWindowController *)controller 
	didSelectTabViewDelegate:(id <TrazzleTabViewDelegate>)aDelegate
{
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(tabViewDelegateDidBecomeActive:)])
			objc_msgSend(plugin, @selector(tabViewDelegateDidBecomeActive:), aDelegate);
	}
}

- (void)windowController:(ZZWindowController *)controller
	didCloseTabViewDelegate:(id <TrazzleTabViewDelegate>)aDelegate
{
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(tabViewDelegateWasClosed:)])
			objc_msgSend(plugin, @selector(tabViewDelegateWasClosed:), aDelegate);
	}
}



#pragma mark -
#pragma mark AMFDuplexGateway delegate methods

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	[self _addConnectionWithRemote:remote];
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote
{
	[self _removeConnectionWithRemote:remote];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[self _addConnectionWithRemote:newSocket];
}



#pragma mark -
#pragma mark CoreService delegate methods

- (void)coreService:(ZZCoreService *)service didReceiveConnectionParams:(NSDictionary *)params
	fromGateway:(AMFRemoteGateway *)gateway
{
	ZZConnection *conn = [self _connectionForRemote:gateway];
	[conn setConnectionParams:params];
}



#pragma mark -
#pragma mark ZZConnectionDelegate methods

- (void)connection:(ZZConnection *)conn didReceiveMessage:(NSString *)message
{
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(trazzleDidReceiveMessage:forConnection:)])
			objc_msgSend(plugin, @selector(trazzleDidReceiveMessage:forConnection:), message, conn);
	}
}

- (void)connectionDidReceiveConnectionSignature:(ZZConnection *)conn
{
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(trazzleDidReceiveSignatureForConnection:)])
			objc_msgSend(plugin, @selector(trazzleDidReceiveSignatureForConnection:), conn);
	}
}

- (void)connectionDidDisconnect:(ZZConnection *)connection
{
	[self _removeConnectionWithRemote:connection.remote];
}

@end