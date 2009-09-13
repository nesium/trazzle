//
//  PluginController.m
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggerPlugin.h"

#define kMMCFG_GlobalPath @"/Library/Application Support/Macromedia/mm.cfg"
#define kMMCFG_LocalPath @"~/mm.cfg"

@interface LoggerPlugin (Private)
- (void)_checkMMCfgs;
- (NSMutableDictionary *)_readMMCfgAtPath:(NSString *)path;
- (BOOL)_validateMMCfg:(NSMutableDictionary *)settings;
- (BOOL)_writeMMCfg:(NSDictionary *)settings toPath:(NSString *)path;
- (void)_cleanupAfterConnection:(ZZConnection *)conn;
- (void)_handleFlashlogMessage:(AbstractMessage *)msg;
- (LPSession *)_createNewSession;
- (LPSession *)_sessionForSwfURL:(NSString *)swfURL;
- (ZZConnection *)_connectionForRemote:(id)remote;
- (LPSession *)_sessionForConnection:(ZZConnection *)conn;
@end


@implementation LoggerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:kFilteringEnabledKey];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:@"LPClearMessagesOnConnection"];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kShowFlashLogMessages];
	[dict setObject:[NSNumber numberWithInt:WBMBringToTop] 
		forKey:@"LPWindowBehaviour"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPDebuggingMode"];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_controller = aController;
		
		m_filterController = [[LPFilterController alloc] init];
		[m_filterController window];
		
		[aController.sharedGateway registerService:[[[LoggingService alloc] initWithDelegate:self] 
			autorelease] withName:@"LoggingService"];
		[aController.sharedGateway registerService:[[[MenuService alloc] initWithDelegate:self] 
			autorelease] withName:@"MenuService"];
		
		// tail flashlog
		m_tailTask = [[NSTask alloc] init];
		m_logPipe = [[NSPipe alloc] init];
		[m_tailTask setLaunchPath:@"/usr/bin/tail"];
		[m_tailTask setArguments:[NSArray arrayWithObjects:@"-F", @"-n", @"0", 
			[@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
				stringByExpandingTildeInPath], nil]];
		[m_tailTask setStandardOutput:m_logPipe];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_logPipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) 
			name:NSTaskDidTerminateNotification object:m_tailTask];
			
		[m_tailTask launch];
		[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
		
		[self _checkMMCfgs];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(applicationWillTerminate:)
			name:NSApplicationWillTerminateNotification object:nil];
			
		m_sessions = [[NSMutableArray alloc] init];
		[self _createNewSession];
	}
	return self;
}

- (void)dealloc
{
	[m_filterController release];
	[super dealloc];
}


- (void)tabViewDelegateDidBecomeActive:(id)aDelegate
{
	if (![aDelegate isKindOfClass:[LPSession class]])
		return;
	LPSession *session = (LPSession *)aDelegate;
	m_filterController.model = session.filterModel;
}

- (void)tabViewDelegateWasClosed:(id)aDelegate
{
	if (![aDelegate isKindOfClass:[LPSession class]])
		return;
	LPSession *session = (LPSession *)aDelegate;
	[m_sessions removeObject:session];
	[(ZZConnection *)[session representedObject] disconnect];
}

- (void)didAddConnection:(ZZConnection *)conn
{
}

- (void)didRemoveConnection:(ZZConnection *)conn
{
	[self _cleanupAfterConnection:conn];
	for (LPSession *session in m_sessions)
	{
		if (session.representedObject == conn)
		{
			session.isDisconnected = YES;
			session.representedObject = nil;
			break;
		}
	}
}

- (void)connectionDidReceiveSignature:(ZZConnection *)conn
{
	NSLog(@"connectionDidReceiveSignature %@", conn);
	LPSession *session = [self _sessionForSwfURL:conn.swfURL];
	session.isDisconnected = NO;
	session.representedObject = conn;
	session.sessionName = conn.applicationName;
	session.swfURL = conn.swfURL;
	[session addConnection:conn];
}



#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[m_tailTask terminate];
	for (ZZConnection *conn in m_controller.connectedClients)
		[self _cleanupAfterConnection:conn];
}



#pragma mark -
#pragma mark Private methods

- (LPSession *)_createNewSession
{
	LPSession *session = [[LPSession alloc] initWithPlugInController:m_controller];
	session.delegate = self;
	[m_sessions addObject:session];
	m_filterController.model = session.filterModel;
	return [session autorelease];
}

- (LPSession *)_sessionForSwfURL:(NSString *)swfURL
{
	for (LPSession *session in m_sessions)
		if ([session.swfURL isEqualToString:swfURL] && session.isDisconnected)
			return session;
	
	for (LPSession *session in m_sessions)
		if (session.representedObject == nil && session.swfURL == nil)
			return session;
	
	return [self _createNewSession];
}

- (ZZConnection *)_connectionForRemote:(id)remote
{
	for (ZZConnection *conn in m_controller.connectedClients)
		if (conn.remote == remote)
			return conn;
	return nil;
}

- (LPSession *)_sessionForConnection:(ZZConnection *)conn
{
	for (LPSession *session in m_sessions)
		if (session.representedObject == conn)
			return session;
	return nil;
}

- (void)_checkMMCfgs
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSMutableDictionary *globalMMCfgContents = nil;
	NSMutableDictionary *localMMCfgContents = nil;
	
	if ([fm fileExistsAtPath:kMMCFG_GlobalPath])
		globalMMCfgContents = [self _readMMCfgAtPath:kMMCFG_GlobalPath];
	
	if (globalMMCfgContents == nil)
		globalMMCfgContents = [NSMutableDictionary dictionary];
	
	if ([fm fileExistsAtPath:[kMMCFG_LocalPath stringByExpandingTildeInPath]])
		localMMCfgContents = [self _readMMCfgAtPath:kMMCFG_LocalPath];
	
	if (localMMCfgContents == nil)
		localMMCfgContents = [NSMutableDictionary dictionary];
	
	if (![self _validateMMCfg:globalMMCfgContents])
		[self _writeMMCfg:globalMMCfgContents toPath:kMMCFG_GlobalPath];

	if (![self _validateMMCfg:localMMCfgContents])
		[self _writeMMCfg:localMMCfgContents toPath:kMMCFG_LocalPath];
}

- (BOOL)_validateMMCfg:(NSMutableDictionary *)settings
{
	NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys: 
		@"1", @"ErrorReportingEnable", 
		@"0", @"MaxWarnings", 
		@"1", @"TraceOutputEnable", 
		[@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
			stringByExpandingTildeInPath], @"TraceOutputFileName", nil];

	BOOL needsSave = NO;
	for (NSString *key in defaultSettings)
	{
		NSString *defaultValue = [defaultSettings objectForKey:key];
		NSString *currentValue = [settings objectForKey:key];
		if (currentValue == nil || ![defaultValue isEqualToString:currentValue])
		{
			[settings setObject:defaultValue forKey:key];
			needsSave = YES;
		}
	}
	return !needsSave;
}

- (NSMutableDictionary *)_readMMCfgAtPath:(NSString *)path
{
	NSError *error;
	NSMutableString *contents = [NSMutableString stringWithContentsOfFile:path 
		encoding:NSUTF8StringEncoding error:&error];
	[contents replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 
		range:(NSRange){0, [contents length]}];
	if (contents == nil)
	{
		return nil;
	}
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	for (NSString *line in lines)
	{
		NSRange equalSignRange = [line rangeOfString:@"="];
		if (equalSignRange.location == NSNotFound)
		{
			continue;
		}
		NSString *key = [line substringToIndex:equalSignRange.location];
		NSString *value = [line substringFromIndex:equalSignRange.location + equalSignRange.length];
		[settings setObject:[value stringByTrimmingCharactersInSet:
			[NSCharacterSet whitespaceCharacterSet]] 
			forKey:[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	return settings;
}

- (BOOL)_writeMMCfg:(NSDictionary *)settings toPath:(NSString *)path
{
	NSMutableString *contents = [NSMutableString string];
	for (NSString *key in settings)
	{
		[contents appendFormat:@"%@=%@\n", key, [settings objectForKey:key]];
	}
	NSError *error;
	return [contents writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
}

- (void)_cleanupAfterConnection:(ZZConnection *)conn
{
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];

	if ([dict objectForKey:@"MenuItem"])
	{
		[m_controller removeStatusMenuItem:[dict objectForKey:@"MenuItem"]];
		[dict removeObjectForKey:@"MenuItem"];
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *imagePath in [dict objectForKey:@"LoggedImages"])
		[fm removeItemAtPath:imagePath error:nil];
}

- (void)_handleFlashlogMessage:(AbstractMessage *)msg
{
	for (LPSession *session in m_sessions)
		[session handleMessage:msg];
}



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification {}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
	[self _handleFlashlogMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:[message htmlEncodedStringWithConvertedLinebreaks]]];
	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
	[message release];
}



#pragma mark -
#pragma mark LoggingService Delegate methods

- (void)loggingService:(LoggingService *)service didReceiveLogMessage:(LogMessage *)message 
		   fromGateway:(AMFRemoteGateway *)gateway
{
	[[self _sessionForConnection:[self _connectionForRemote:gateway]] handleMessage:message];
}

- (void)loggingService:(LoggingService *)service didReceivePNG:(NSString *)path withSize:(NSSize)size
		   fromGateway:(AMFRemoteGateway *)gateway
{
	ZZConnection *conn = [self _connectionForRemote:gateway];
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];
	
	if ([dict objectForKey:@"LoggedImages"] == nil)
		[dict setObject:[NSMutableArray array] forKey:@"LoggedImages"];
	[(NSMutableArray *)[dict objectForKey:@"LoggedImages"] addObject:path];
	
	AbstractMessage *msg = [[AbstractMessage alloc] init];
	msg.message = [NSString stringWithFormat:@"<img src='%@' width='%d' height='%d' />", path, 
				   (int)size.width, (int)size.height];
	[[self _sessionForConnection:conn] handleMessage:msg];
	[msg release];
}



#pragma mark -
#pragma mark MenuService Delegate methods

- (void)menuService:(MenuService *)service didReceiveMenu:(NSMenu *)menu 
		fromGateway:(AMFRemoteGateway *)gateway
{
	ZZConnection *conn = [self _connectionForRemote:gateway];
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];
	LPSession *session = [self _sessionForConnection:conn];
	
	if ([dict objectForKey:@"MenuItem"])
	{
		[m_controller removeStatusMenuItem:[dict objectForKey:@"MenuItem"]];
		[dict removeObjectForKey:@"MenuItem"];
	}
	
	NSMenuItem *item = [[NSMenuItem alloc] init];
	[item setTitle:session.sessionName];
	[item setSubmenu:menu];
	[dict setObject:item forKey:@"MenuItem"];
	[m_controller addStatusMenuItem:item];
	[item release];
}



#pragma mark -
#pragma mark StatusMenuItem actions

- (void)statusMenuItemWasClicked:(NSMenuItem *)sender
{	
	NSMenu *lastMenu = [sender menu];
	NSMenu *parent = [lastMenu supermenu];
	NSMutableArray *indexes = [NSMutableArray arrayWithObject:
		[NSNumber numberWithInt:[lastMenu indexOfItem:sender]]];
	while (parent)
	{
		for (ZZConnection *conn in m_controller.connectedClients)
		{
			if ([[[conn storageForPluginWithName:@"LoggerPlugin"] 
				objectForKey:@"MenuItem"] menu] == parent)
			{
				[(AMFRemoteGateway *)conn.remote invokeRemoteService:@"MenuService" 
								 methodName:@"performClickOnMenuItemWithIndexPath" 
								  arguments:indexes, nil];
				return;
			}
		}
		
		for (int32_t i = 0; i < [[parent itemArray] count]; i++)
		{
			NSMenuItem *item = [[parent itemArray] objectAtIndex:i];
			if ([item submenu] == lastMenu)
			{
				[indexes insertObject:[NSNumber numberWithInt:i] atIndex:0];
			}
		}
		
		lastMenu = parent;
		parent = [lastMenu supermenu];
	}
}

@end