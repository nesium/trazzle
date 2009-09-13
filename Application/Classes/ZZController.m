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
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (id)init
{
	if (self = [super init])
	{
		// start server
		m_connectedClients = [[NSMutableArray alloc] init];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		m_gateway = [[AMFDuplexGateway alloc] init];
		m_gateway.delegate = self;
		[m_gateway registerService:[[[ZZCoreService alloc] initWithDelegate:self] autorelease] 
			withName:@"CoreService"];
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

- (void)showTrazzleWindow:(id)sender
{
	[m_windowController showWindow:self];
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
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(didAddConnection:)])
			objc_msgSend(plugin, @selector(didAddConnection:), client);
	}
	[client release];
}

- (void)_removeConnectionWithRemote:(id)remote
{
	ZZConnection *conn = [self _connectionForRemote:remote];
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(didRemoveConnection:)])
			objc_msgSend(plugin, @selector(didRemoveConnection:), conn);
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
	for (NSObject <TrazzlePlugIn> *plugin in m_loadedPlugins)
	{
		if ([plugin respondsToSelector:@selector(connectionDidReceiveSignature:)])
			objc_msgSend(plugin, @selector(connectionDidReceiveSignature:), conn);
	}
}



#pragma mark -
#pragma mark ZZConnectionDelegate methods

- (void)connection:(ZZConnection *)client didReceiveMessage:(NSString *)message
{
}

- (void)connectionDidDisconnect:(ZZConnection *)connection
{
	[self _removeConnectionWithRemote:connection.remote];
}

@end