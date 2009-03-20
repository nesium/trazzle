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
- (LoggingClient *)_clientForGateway:(AMFRemoteGateway *)gateway;
- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client;
- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client;
- (void)_checkMMCfgs;
- (NSMutableDictionary *)_readMMCfgAtPath:(NSString *)path;
- (BOOL)_validateMMCfg:(NSMutableDictionary *)settings;
- (BOOL)_writeMMCfg:(NSDictionary *)settings toPath:(NSString *)path;
- (void)_handleFlashlogLine:(NSString *)message;
- (void)_finishFlashLogException;
- (void)_tryFinishFlashLogException;
@end


@implementation LoggerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:3456] forKey:@"LPServerPort"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPEnableFiltering"];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:@"LPClearMessagesOnConnection"];
	[dict setObject:[NSNumber numberWithInt:WBMBringToTop] 
		forKey:@"LPWindowBehaviour"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPDebuggingMode"];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		controller = aController;
		
		m_filterController = [[LPFilterController alloc] init];
		m_filterController.delegate = self;
		
		// display viewcontroller
		m_loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LogWindow" 
			bundle:[NSBundle bundleForClass:[self class]]];
		m_loggingViewController.delegate = self;
		[controller addTabWithIdentifier:@"Foo" view:[m_loggingViewController view] delegate:self];
		
		// alloc model
		m_messageModel = [[MessageModel alloc] init];
		m_messageModel.delegate = self;
		
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
		[m_gateway registerService:[[[LoggingService alloc] initWithDelegate:self] autorelease] 
			withName:@"LoggingService"];
		m_gateway.delegate = self;
		[m_gateway startOnPort:(port + 1) error:&error];
		
		// start debugger
		//m_debuggingServer = [[FDBServer alloc] init];
		
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
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[m_connectedClients release];
	[m_messageModel release];
	[m_filterController release];
	[super dealloc];
}



#pragma mark -
#pragma mark TrazzleTabViewDelegate methods

- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier
{
	return [event keyCode] == 51 || [event keyCode] == 117;
}

- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier
{
	if ([event keyCode] == 51 || [event keyCode] == 117)
	{
		[m_messageModel clearAllMessages];
		[m_loggingViewController clearAllMessages];
	}
	return YES;
}

- (NSString *)titleForTabWithIdentifier:(NSString *)identifier
{
	return @"New Session";
}



#pragma mark -
#pragma mark Private methods

- (LoggingClient *)_clientForGateway:(AMFRemoteGateway *)gateway
{
	for (LoggingClient *client in m_connectedClients)
		if (client.gateway == gateway)
			return client;
	return nil;
}

- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client
{
	if ([m_messageModel numberOfMessages] == 0)
		[controller bringWindowToTop];
	[m_messageModel addMessage:msg];
	[m_loggingViewController sendMessage:msg];
}

- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client
{
	if (msg.type == kCommandActionTypeUpdateStatusBar)
	{
		if (client.statusMenuItem)
		{
			[controller removeStatusMenuItem:client.statusMenuItem];
		}
		if (msg.data)
		{
			client.statusMenuItem = [[NSMenuItem alloc] init];
			[client.statusMenuItem setTitle:@"Untitled"];
			NSMenu *menu = [[NSMenu alloc] init];
			[client.statusMenuItem setSubmenu:menu];
			for (NSMenuItem *menuItem in (NSArray *)msg.data)
			{
				[menu addItem:menuItem];
			}
			[menu release];
		}
		else
		{
			client.statusMenuItem = nil;
		}
		if (client.statusMenuItem)
		{
			[controller addStatusMenuItem:client.statusMenuItem];
		}
	}
	else if (msg.type == kCommandActionTypeStartFileMonitoring)
	{
		[[FileMonitor sharedMonitor] addObserver:client 
			forFileAtPath:[msg.attributes objectForKey:@"path"]];
	}
	else if (msg.type == kCommandActionTypeStopFileMonitoring)
	{
		[[FileMonitor sharedMonitor] removeObserver:client 
			forFileAtPath:[msg.attributes objectForKey:@"path"]];
	}
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
	
	if (message && [message rangeOfString:@"Error: Error #"].location != NSNotFound)
	{
		m_currentException = [[ExceptionMessage alloc] init];
		m_currentExceptionStacktrace = [[NSMutableString alloc] initWithFormat:@"%@\n", message];
		m_currentException.levelName = @"exception";
		NSRange colonRange = [message rangeOfString:@":"];
		m_currentException.errorType = [message substringToIndex:colonRange.location];
		NSUInteger startIndex = colonRange.location + colonRange.length;
		NSRange hashRange = [message rangeOfString:@"#" options:0 
			range:(NSRange){startIndex, [message length] - startIndex}];
		colonRange = [message rangeOfString:@":" options:0 
			range:(NSRange){startIndex, [message length] - startIndex}];
		m_currentException.errorNumber = [[message substringWithRange:(NSRange){hashRange.location + 
			hashRange.length, colonRange.location - hashRange.location - hashRange.length}] intValue];
		m_currentException.message = [NSString stringWithFormat:@"%@ (#%d): %@",
			m_currentException.errorType, m_currentException.errorNumber, 
			[message substringFromIndex:colonRange.location + 2]];
		return;
	}

	[self _handleMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:[message htmlEncodedStringWithConvertedLinebreaks]] fromClient:nil];
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
	[self _handleMessage:m_currentException fromClient:nil];
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



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification
{
}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
	
	if (m_flashlogBuffer != nil)
	{
		message = [[m_flashlogBuffer stringByAppendingString:message] retain];
		[m_flashlogBuffer release];
		m_flashlogBuffer = nil;
	}
	
	NSArray *lines = [message componentsSeparatedByString:@"\n"];
	for (uint32_t i = 0; i < [lines count]; i++)
	{
		NSString *line = [lines objectAtIndex:i];
		if (i == [lines count] - 1)
		{
			if ([line length] > 0) m_flashlogBuffer = [line retain];
			else [self _tryFinishFlashLogException];
		}
		else if ([line length] > 0)
			[self _handleFlashlogLine:line];
	}

	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
	[message release];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[m_messageModel clearAllMessages];
	[m_loggingViewController clearAllMessages];
	
	LoggingClient *client = [[LoggingClient alloc] initWithSocket:newSocket];
	client.delegate = self;
	[m_connectedClients addObject:client];
	[client release];
}



#pragma mark -
#pragma mark AMFDuplexGateway delegate methods

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	[m_messageModel clearAllMessages];
	[m_loggingViewController clearAllMessages];
	
	LoggingClient *client = [[LoggingClient alloc] initWithGateway:remote];
	client.delegate = self;
	[m_connectedClients addObject:client];
	[client release];
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote
{
	[self clientDidDisconnect:[self _clientForGateway:remote]];
}



#pragma mark -
#pragma mark LoggingClient delegate methods

- (void)client:(LoggingClient *)client didReceiveMessage:(NSString *)message
{
	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message delegate:self];
	AbstractMessage *msg = (AbstractMessage *)[[parser data] objectAtIndex:0];

	if (msg.messageType == kLPMessageTypeCommand)
		[self _handleCommandMessage:(CommandMessage *)msg fromClient:client];
	else
		[self _handleMessage:msg fromClient:client];
	[parser release];
}

- (void)clientDidDisconnect:(LoggingClient *)client
{
	if (client.statusMenuItem)
	{
		[controller removeStatusMenuItem:client.statusMenuItem];
	}
	[m_connectedClients removeObject:client];
}



#pragma mark -
#pragma mark LoggingService Delegate methods

- (void)loggingService:(LoggingService *)service didReceiveLogMessage:(LogMessage *)message 
	fromGateway:(AMFRemoteGateway *)gateway
{
	[self _handleMessage:message fromClient:nil];
}

- (void)loggingService:(LoggingService *)service didReceivePNG:(NSString *)path 
	fromGateway:(AMFRemoteGateway *)gateway
{
	AbstractMessage *msg = [[AbstractMessage alloc] init];
	msg.message = [NSString stringWithFormat:@"<img src='%@'/>", path];
	[self _handleMessage:msg fromClient:nil];
	[msg release];
}



#pragma mark -
#pragma mark LoggingViewController delegate methods

- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
	messageAtIndex:(uint32_t)index
{
	return [m_messageModel messageAtIndex:index];
}



#pragma mark -
#pragma mark MessageParser delegate methods

- (void)parser:(MessageParser *)parser didParseMenuItem:(NSMenuItem *)menuItem
{
	[menuItem setTarget:self];
	[menuItem setAction:@selector(statusMenuItemWasClicked:)];
}



#pragma mark -
#pragma mark FilterController delegate methods

- (void)filterController:(LPFilterController *)controller didSelectFilter:(LPFilter *)filter
{
	m_messageModel.filter = filter;
}

- (void)filterController:(LPFilterController *)controller 
	didChangeFilteringEnabledFlag:(BOOL)isEnabled
{
	[m_messageModel setFilter:(isEnabled ? [m_filterController activeFilter] : nil)];
}



#pragma mark -
#pragma mark MessageModel delegate methods

- (void)messageModel:(MessageModel *)model didHideMessagesWithIndexes:(NSArray *)indexes
{
	[m_loggingViewController hideMessagesWithIndexes:indexes];
}

- (void)messageModel:(MessageModel *)model didShowMessagesWithIndexes:(NSArray *)indexes
{
	[m_loggingViewController showMessagesWithIndexes:indexes];
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
		for (LoggingClient *client in m_connectedClients)
		{
			if ([client.statusMenuItem menu] == parent)
			{
				[client sendEventWithType:kEventStatusItemClicked attributes:
					[NSDictionary dictionaryWithObject:[indexes componentsJoinedByString:@"-"] 
						forKey:@"indexes"]];
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