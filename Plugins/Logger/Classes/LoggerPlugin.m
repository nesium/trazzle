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
- (void)_handleFlashlogLine:(NSString *)message;
- (void)_finishFlashLogException;
- (void)_tryFinishFlashLogException;
- (void)_cleanupAfterRemoteGateway:(LPRemoteGateway *)remote;
- (void)_handleFlashlogMessage:(AbstractMessage *)msg;
- (LPSession *)_createNewSession;
@end


@implementation LoggerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:3456] forKey:@"LPServerPort"];
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
		
		// start server
		m_connectedClients = [[NSMutableArray alloc] init];
		NSError *error;
		uint16_t port = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
			valueForKey:@"LPServerPort"] shortValue];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		if (![m_socket acceptOnPort:port error:&error])
		{
			NSLog(@"Could not start server on port %d", port);
		}
		
		// start AMF server
		error = nil;
		m_gateway = [[AMFDuplexGateway alloc] init];
		[m_gateway setRemoteGatewayClass:[LPRemoteGateway class]];
		[m_gateway registerService:[[[LoggingService alloc] init] autorelease] 
			withName:@"LoggingService"];
		[m_gateway registerService:[[[MenuService alloc] init] autorelease] 
			withName:@"MenuService"];
		m_gateway.delegate = self;
		[m_gateway startOnPort:(port + 1) error:&error];
		
		// tail flashlog
		m_currentException = nil;
		m_flashlogBuffer = nil;
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
	[m_socket release];
	[m_connectedClients release];
	[m_filterController release];
	[super dealloc];
}



#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[m_tailTask terminate];
	for (LPRemoteGateway *remote in m_gateway.remoteGateways)
		[self _cleanupAfterRemoteGateway:remote];
}



#pragma mark -
#pragma mark Private methods

- (LPSession *)_createNewSession
{
	LPSession *session = [[LPSession alloc] initWithPlugInController:m_controller];
	[m_sessions addObject:session];
	m_filterController.model = session.filterModel;
	return [session autorelease];
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

- (void)_handleFlashlogLine:(NSString *)message
{
	if (m_currentException != nil)
	{
		if ([message hasPrefix:@"\tat "])
		{
			[m_currentExceptionStacktrace appendFormat:@"%@\n", message];
			return;
		}
		else
		{
			[self _finishFlashLogException];
		}
	}
	
//	if (message && [message rangeOfString:@"Error: Error #"].location != NSNotFound)
//	{
//		m_currentException = [[ExceptionMessage alloc] init];
//		m_currentExceptionStacktrace = [[NSMutableString alloc] initWithFormat:@"%@\n", message];
//		m_currentException.levelName = @"exception";
//		NSRange colonRange = [message rangeOfString:@":"];
//		m_currentException.errorType = [message substringToIndex:colonRange.location];
//		NSUInteger startIndex = colonRange.location + colonRange.length;
//		NSRange hashRange = [message rangeOfString:@"#" options:0 
//			range:(NSRange){startIndex, [message length] - startIndex}];
//		colonRange = [message rangeOfString:@":" options:0 
//			range:(NSRange){startIndex, [message length] - startIndex}];
//		m_currentException.errorNumber = [[message substringWithRange:(NSRange){hashRange.location + 
//			hashRange.length, colonRange.location - hashRange.location - hashRange.length}] intValue];
//		m_currentException.message = [NSString stringWithFormat:@"%@ (#%d): %@",
//			m_currentException.errorType, m_currentException.errorNumber, 
//			[message substringFromIndex:colonRange.location + 2]];
//		return;
//	}

	[self _handleFlashlogMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:[message htmlEncodedStringWithConvertedLinebreaks]]];
}

- (void)_finishFlashLogException
{
	if (m_currentException == nil)
		return;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
		selector:@selector(_finishFlashLogException) object:nil];
	
	NSArray *stacktrace = [StackTraceParser parseAS3StackTrace:m_currentExceptionStacktrace];
	if ([stacktrace count] > 0)
	{
		StackTraceItem *item = [stacktrace objectAtIndex:0];
		m_currentException.fullClassName = item.fullClassName;
		m_currentException.method = item.method;
		m_currentException.file = item.file;
		m_currentException.line = item.line;
		[m_currentException setStacktrace:[stacktrace subarrayWithRange:
			(NSRange){1, [stacktrace count] - 1}]];
	}
	[self _handleFlashlogMessage:m_currentException];
	[m_currentException release];
	[m_currentExceptionStacktrace release];
	m_currentException = nil;
	m_currentExceptionStacktrace = nil;
}

- (void)_tryFinishFlashLogException
{
	if (m_currentException == nil)
		return;
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
		selector:@selector(_finishFlashLogException) object:nil];
	[self performSelector:@selector(_finishFlashLogException) withObject:nil afterDelay:1.0/10.0];
}

- (void)_cleanupAfterRemoteGateway:(LPRemoteGateway *)remote
{
	if ([(LPRemoteGateway *)remote menuItem])
	{
		[m_controller removeStatusMenuItem:remote.menuItem];
		remote.menuItem = nil;
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *imagePath in remote.loggedImages)
		[fm removeItemAtPath:imagePath error:nil];
}

- (void)_handleFlashlogMessage:(AbstractMessage *)msg
{
	for (LPSession *session in m_sessions)
		[session handleFlashlogMessage:msg];
}



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification
{
}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];

	[self _handleFlashlogMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:[message htmlEncodedStringWithConvertedLinebreaks]]];
	
//	if (m_flashlogBuffer != nil)
//	{
//		message = [[m_flashlogBuffer stringByAppendingString:message] retain];
//		[m_flashlogBuffer release];
//		m_flashlogBuffer = nil;
//	}
	
//	NSArray *lines = [message componentsSeparatedByString:@"\n"];
//	for (uint32_t i = 0; i < [lines count]; i++)
//	{
//		NSString *line = [lines objectAtIndex:i];
//		if (i == [lines count] - 1)
//		{
//			if ([line length] > 0) m_flashlogBuffer = [line retain];
//			else [self _tryFinishFlashLogException];
//		}
//		else if ([line length] > 0)
//			[self _handleFlashlogLine:line];
//	}

	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
	[message release];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
//	[m_messageModel clearAllMessages];
//	[m_loggingViewController clearAllMessages];
	
	LoggingClient *client = [[LoggingClient alloc] initWithSocket:newSocket];
	[m_connectedClients addObject:client];
	[client release];
	
	LPSession *session = [self _createNewSession];
	[session addLoggingClient:client];
}



#pragma mark -
#pragma mark AMFDuplexGateway delegate methods

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	LPSession *session = [self _createNewSession];
	[session addRemoteGateway:(LPRemoteGateway *)remote];
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote
{
	[self _cleanupAfterRemoteGateway:(LPRemoteGateway *)remote];
}



#pragma mark -
#pragma mark StatusMenuItem actions

- (void)statusMenuItemWasClicked:(NSMenuItem *)sender
{	
	NSMenu *lastMenu = [sender menu];
	NSMenu *parent = [lastMenu supermenu];
	NSMutableArray *indexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:
															   [lastMenu indexOfItem:sender]]];
	while (parent)
	{
		for (LPRemoteGateway *client in [m_gateway remoteGateways])
		{
			if ([client.menuItem menu] == parent)
			{
				[client invokeRemoteService:@"MenuService" 
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