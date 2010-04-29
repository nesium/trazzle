//
//  PluginController.m
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LPLoggerPlugin.h"

#define kUserDefaultsObservationContext 1
#define kSessionObservationContext 2

@interface LPLoggerPlugin (Private)
- (void)_checkMMCfgs;
- (void)_cleanupAfterConnection:(ZZConnection *)conn;
- (LPSession *)_createNewSession;
- (void)_destroySession:(LPSession *)session;
- (LPSession *)_sessionForSwfURL:(NSURL *)swfURL;
- (LPSession *)_sessionForConnection:(ZZConnection *)conn;
- (void)_updateWindowLevel:(BOOL)justConnected;
- (BOOL)_hasActiveSession;
- (void)_handleMessage:(AbstractMessage *)message fromConnection:(ZZConnection *)connection;
@end


@implementation LPLoggerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

+ (void)initialize{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:kFilteringEnabledKey];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kShowFlashLogMessages];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:kKeepAlwaysOnTop];
	[dict setObject:[NSNumber numberWithInt:kTabBehaviourOneForSameURL] forKey:kTabBehaviour];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kReuseTabs];
	[dict setObject:[NSNumber numberWithInt:WBMBringToTop] forKey:kWindowBehaviour];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:kKeepWindowOnTopWhileConnected];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kClearMessagesOnNewConnection];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kClearFlashLogMessagesOnNewConnection];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kAutoSelectNewTab];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:kShowTextMateLinks];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPDebuggingMode"];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (id)initWithPlugInController:(ZZPlugInController *)aController{
	if (self = [super init]){
		m_controller = aController;
		
		m_filterController = [[LPFilterWindowController alloc] init];
		[m_filterController window];
		
		[aController.sharedGateway registerService:[[[LoggingService alloc] initWithDelegate:self] 
			autorelease] withName:@"LoggingService"];
		[aController.sharedGateway registerService:[[[MenuService alloc] initWithDelegate:self] 
			autorelease] withName:@"MenuService"];
		[aController.sharedGateway registerService:[[[FileObservingService alloc] 
			initWithDelegate:self] autorelease] withName:@"FileObservingService"];
		
		// tail flashlog
		NSString *flashLogPath = [@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
				stringByExpandingTildeInPath];
		m_tailTask = [[LPTailTask alloc] initWithFile:flashLogPath delegate:self];
		[m_tailTask launch];
		
		[self _checkMMCfgs];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(applicationWillTerminate:)
			name:NSApplicationWillTerminateNotification object:nil];
			
		m_sessions = [[NSMutableArray alloc] init];
		[self _createNewSession];
		
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults addObserver:self 
			forKeyPath:[NSString stringWithFormat:@"values.%@", kKeepAlwaysOnTop] 
			options:0 context:(void *)kUserDefaultsObservationContext];
		[defaults addObserver:self 
			forKeyPath:[NSString stringWithFormat:@"values.%@", kKeepWindowOnTopWhileConnected] 
			options:0 context:(void *)kUserDefaultsObservationContext];
		
		// we cache this preference, since the flag is checked on every incoming message
		// (see _handleMessage:fromConnection:)
		m_autoSelectTab = [[[defaults values] valueForKey:kAutoSelectNewTab] boolValue];
		[defaults addObserver:self 
			forKeyPath:[NSString stringWithFormat:@"values.%@", kAutoSelectNewTab] 
			options:0 context:(void *)kUserDefaultsObservationContext];
		
		// apply window preferences, like "keep trazzle always on top"
		[self _updateWindowLevel:NO];
	}
	return self;
}

- (void)dealloc{
	[m_filterController release];
	[super dealloc];
}


- (void)tabViewDelegateDidBecomeActive:(id)aDelegate{
	if (![aDelegate isKindOfClass:[LPSession class]])
		return;
	LPSession *session = (LPSession *)aDelegate;
	m_filterController.model = session.filterModel;
}

- (void)tabViewDelegateWasClosed:(id)aDelegate{
	if (![aDelegate isKindOfClass:[LPSession class]])
		return;
	LPSession *session = (LPSession *)aDelegate;
	[self _destroySession:session];
}

- (void)trazzleDidOpenConnection:(ZZConnection *)conn{
}

- (void)trazzleDidCloseConnection:(ZZConnection *)conn{
	[self _cleanupAfterConnection:conn];
	for (LPSession *session in m_sessions){
		if ([session containsConnection:conn])
			[session removeConnection:conn];
	}
	[self _updateWindowLevel:NO];
}

- (void)trazzleDidReceiveSignatureForConnection:(ZZConnection *)conn{
	LPSession *session = [self _sessionForSwfURL:conn.swfURL];
	[session addConnection:conn];
	
	NSDictionary *playerParams = [conn.connectionParams objectForKey:@"player"];
	if (!playerParams)
		return;
	NSString *playerVersion = [playerParams objectForKey:@"version"];
	BOOL isDebugger = [[playerParams objectForKey:@"isDebugger"] boolValue];
	NSMutableString *msg = [NSMutableString string];
	[msg appendFormat:@"Player Version: %@.", playerVersion];
	[msg appendFormat:@" Is Debug Player: %@.", isDebugger ? @"Yes" : @"<span class='error'>No</span>"];
	if (!isDebugger){
		[msg appendFormat:@"<br/>In order to enable the complete feature set of Trazzle, you should use the Debug Player."];
	}
	AbstractMessage *message = [AbstractMessage messageWithType:kLPMessageTypeSystem message:msg];
	[self _handleMessage:message fromConnection:conn];
}

- (void)trazzleDidReceiveMessage:(NSString *)message forConnection:(ZZConnection *)conn{
	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message];
	AbstractMessage *msg = (AbstractMessage *)[[parser data] objectAtIndex:0];
	
	if (conn.applicationName == nil && msg.messageType != kLPMessageTypeConnectionSignature){
		[conn disconnect];
		goto bailout;
	}
	
	if (msg.messageType == kLPMessageTypeConnectionSignature){
		ConnectionSignature *sig = (ConnectionSignature *)msg;
		[conn setConnectionParams:[NSDictionary dictionaryWithObjectsAndKeys:
			sig.applicationName, @"applicationName", 
			sig.swfURL, @"swfURL", nil]];
		goto bailout;
	}
	
	if (msg.messageType == kLPMessageTypeCommand)
		NSLog(@"Command message are temporarly disabled!");
	else
		[self _handleMessage:msg fromConnection:conn];
	
	bailout:
		[parser release];
}

- (void)prefPane:(NSViewController **)viewController icon:(NSImage **)icon{
	*viewController = [[[LPPreferencesViewController alloc] initWithNibName:@"Preferences" 
		bundle:[NSBundle bundleForClass:[self class]]] autorelease];
	*icon = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] 
		pathForResource:@"LoggingIcon" ofType:@"png"]] autorelease];
}



#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)aNotification{
	[m_tailTask terminate];
	for (ZZConnection *conn in m_controller.connectedClients)
		[self _cleanupAfterConnection:conn];
}



#pragma mark -
#pragma mark Bindings notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context{
	if ((int)context == kUserDefaultsObservationContext){
		if ([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", kKeepAlwaysOnTop]] || 
			[keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", 
				kKeepWindowOnTopWhileConnected]]){
			[self _updateWindowLevel:NO];
		}else if ([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", 
			kAutoSelectNewTab]]){
			m_autoSelectTab = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
				valueForKey:kAutoSelectNewTab] boolValue];
		}
	}else if ((int)context == kSessionObservationContext){
		if ([keyPath isEqualToString:@"isReady"]){
			BOOL autoSelectTab = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
				valueForKey:kAutoSelectNewTab] boolValue];
			if (autoSelectTab)
				[m_controller selectTabItemWithDelegate:(LPSession *)object];
		}
	}
}



#pragma mark -
#pragma mark Private methods

- (LPSession *)_createNewSession{
	LPSession *session = [[LPSession alloc] initWithPlugInController:m_controller];
	session.delegate = self;
	[session addObserver:self forKeyPath:@"isReady" options:0 
		context:(void *)kSessionObservationContext];
	[m_sessions addObject:session];
	m_filterController.model = session.filterModel;
	return [session autorelease];
}

- (void)_destroySession:(LPSession *)session{
	[session removeObserver:self forKeyPath:@"isReady"];
	[m_sessions removeObject:session];
	for (ZZConnection *conn in [session representedObjects])
		[conn disconnect];
}

- (LPSession *)_sessionForSwfURL:(NSURL *)swfURL{
	TabBehaviourMode tmode = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		valueForKey:kTabBehaviour] intValue];

	if (tmode == kTabBehaviourOneForAll && [m_sessions count])
		return [m_sessions objectAtIndex:0];

	for (LPSession *session in m_sessions){
		if (session.isPristine || 
			([session.swfURL isEqual:swfURL] && 
			(session.isDisconnected || tmode == kTabBehaviourOneForSameURL))){
			if (m_autoSelectTab){
				[m_controller selectTabItemWithDelegate:session];
			}
			return session;
		}
	}
	return [self _createNewSession];
}

- (LPSession *)_sessionForConnection:(ZZConnection *)conn{
	for (LPSession *session in m_sessions)
		if ([session.representedObjects aa_containsPointer:conn])
			return session;
	return nil;
}

- (BOOL)_hasActiveSession{
	for (LPSession *session in m_sessions)
		if (!session.isDisconnected)
			return YES;
	return NO;
}

- (void)_checkMMCfgs{
	NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys: 
		@"1", @"ErrorReportingEnable", 
		@"0", @"MaxWarnings", 
		@"1", @"TraceOutputEnable", 
		[@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
			stringByExpandingTildeInPath], @"TraceOutputFileName", nil];
	
	LPMMCfgFile *mmCfg = [LPMMCfgFile mmCfgWithContentsOfFile:kMMCfgGlobalPath error:nil];
	[mmCfg setValuesForKeysWithDictionary:defaultSettings];
	[mmCfg writeToFile:kMMCfgGlobalPath atomically:NO error:nil];
	
	NSString *path = [kMMCfgLocalPath stringByExpandingTildeInPath];
	mmCfg = [LPMMCfgFile mmCfgWithContentsOfFile:path error:nil];
	[mmCfg setValuesForKeysWithDictionary:defaultSettings];
	[mmCfg writeToFile:path atomically:NO error:nil];
}

- (void)_cleanupAfterConnection:(ZZConnection *)conn{
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];
	
	if ([dict objectForKey:@"MenuItem"]){
		[m_controller removeStatusMenuItem:[dict objectForKey:@"MenuItem"]];
		[dict removeObjectForKey:@"MenuItem"];
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *imagePath in [dict objectForKey:@"LoggedImages"])
		[fm removeItemAtPath:imagePath error:nil];
}

- (void)_updateWindowLevel:(BOOL)justConnected{
	NSObject *values = [[NSUserDefaultsController sharedUserDefaultsController] values];
	BOOL keepWindowOnTop = [[values valueForKey:kKeepAlwaysOnTop] boolValue];
	BOOL keepWindowOnTopWhileConnected = [[values valueForKey:kKeepWindowOnTopWhileConnected] 
		boolValue];
		
	if (keepWindowOnTop || (keepWindowOnTopWhileConnected && [self _hasActiveSession])){
		[m_controller setWindowIsFloating:YES];
		return;
	}
	
	[m_controller setWindowIsFloating:NO];
	WindowBehaviourMode wmode = [[values valueForKey:kWindowBehaviour] intValue];
	if (wmode == WBMBringToTop && justConnected)
		[m_controller bringWindowToTop];
}

- (void)_handleMessage:(AbstractMessage *)message fromConnection:(ZZConnection *)connection{
	// a flashlog message
	if (connection == nil){
		for (LPSession *session in m_sessions)
			[session handleMessage:message];
	}else{
		LPSession *session = [self _sessionForConnection:connection];
		[session handleMessage:message];
		// bring window to front for non flashlog messages and only if it hasn't been brought 
		// to front by this connection
		NSMutableDictionary *storage = [connection storageForPluginWithName:@"LoggerPlugin"];
		if ([storage objectForKey:@"HasSentMessages"] == nil){
			[storage setObject:[NSNumber numberWithBool:YES] forKey:@"HasSentMessages"];
			[self _updateWindowLevel:YES];
		}
		// if the targeted session is not the active tab, we try to make it active if the 
		// currently selected tab contains either a inactive session or hasn't received messages 
		// for at least 10 seconds (to prevent nervous flipping between tabs)
		// if the active tab delegate is not an instance of LPSession, we do nothing
		id activeTabDelegate = [m_controller selectedTabDelegate];
		if (session != activeTabDelegate && m_autoSelectTab){
			NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
			if ([activeTabDelegate isMemberOfClass:[LPSession class]]){
				LPSession *activeSession = (LPSession *)activeTabDelegate;
				if (activeSession.isReady && (activeSession.isDisconnected || 
					currentTime - activeSession.lastLogMessageTimestamp >= 10.0)){
					[m_controller selectTabItemWithDelegate:session];
				}
			}
		}
	}
}

- (void)_notifyConnectionsAboutChangedFile:(NSString *)path{
	for (ZZConnection *conn in m_controller.connectedClients){
		NSMutableDictionary *storage = [conn storageForPluginWithName:@"LoggerPlugin"];
		NSMutableSet *observedPaths = [storage objectForKey:@"ObservedPaths"];
		if ([observedPaths containsObject:path]){
			if (conn.isLegacyConnection){
				[conn sendString:[NSString stringWithFormat:
					@"<event type=\"fileChange\" path=\"%@\"/>", path]];
			}else{
				AMFRemoteGateway *gateway = conn.remote;
				[gateway invokeRemoteService:@"FileObservingService" methodName:@"fileDidChange" 
					arguments:path, nil];
			}
		}
	}
}



#pragma mark -
#pragma mark TailTaskDelegate methods

- (void)tailTask:(LPTailTask *)task didReceiveLine:(NSString *)line{
	[self _handleMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:[line htmlEncodedStringWithConvertedLinebreaks]] fromConnection:nil];
}



#pragma mark -
#pragma mark LoggingService Delegate methods

- (void)loggingService:(LoggingService *)service didReceiveLogMessage:(LogMessage *)message 
		   fromGateway:(AMFRemoteGateway *)gateway{
	[self _handleMessage:message fromConnection:[m_controller connectionForRemote:gateway]];
}

- (void)loggingService:(LoggingService *)service didReceivePNG:(NSString *)path withSize:(NSSize)size
		   fromGateway:(AMFRemoteGateway *)gateway{
	ZZConnection *conn = [m_controller connectionForRemote:gateway];
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];
	
	if ([dict objectForKey:@"LoggedImages"] == nil)
		[dict setObject:[NSMutableArray array] forKey:@"LoggedImages"];
	[(NSMutableArray *)[dict objectForKey:@"LoggedImages"] addObject:path];
	
	AbstractMessage *msg = [[AbstractMessage alloc] init];
	msg.messageType = kLPMessageTypeBitmap;
	msg.message = [NSString stringWithFormat:@"<img src='%@' width='%d' height='%d' />", path, 
				   (int)size.width, (int)size.height];
	[self _handleMessage:msg fromConnection:conn];
	[msg release];
}



#pragma mark -
#pragma mark MenuService Delegate methods

- (void)menuService:(MenuService *)service didReceiveMenu:(NSMenu *)menu 
		fromGateway:(AMFRemoteGateway *)gateway{
	ZZConnection *conn = [m_controller connectionForRemote:gateway];
	NSMutableDictionary *dict = [conn storageForPluginWithName:@"LoggerPlugin"];
	LPSession *session = [self _sessionForConnection:conn];
	
	if ([dict objectForKey:@"MenuItem"]){
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
#pragma mark FileObservingService Delegate methods

- (void)fileObservingService:(FileObservingService *)service 
	didReceiveObservingMessageForPath:(NSString *)aPath 
	shouldStopObserving:(BOOL)shouldStop 
	fromGateway:(AMFRemoteGateway *)gateway{
	ZZConnection *conn = [m_controller connectionForRemote:gateway];
	NSMutableDictionary *storage = [conn storageForPluginWithName:@"LoggerPlugin"];
	NSMutableSet *observedPaths = [storage objectForKey:@"ObservedPaths"];
	if (shouldStop){
		[observedPaths removeObject:aPath];
		[[FileMonitor sharedMonitor] removeObserver:self forFileAtPath:aPath];
	}else{
		if (!observedPaths){
			observedPaths = [NSMutableSet set];
			[storage setObject:observedPaths forKey:@"ObservedPaths"];
		}
		[observedPaths addObject:aPath];
		[[FileMonitor sharedMonitor] addObserver:self forFileAtPath:aPath];
	}
}



#pragma mark -
#pragma mark FileObserver Protocol methods

- (void)fileMonitor:(FileMonitor *)fm fileDidChangeAtPath:(NSString *)path{
	[self performSelectorOnMainThread:@selector(_notifyConnectionsAboutChangedFile:) 
		withObject:path waitUntilDone:NO];
}



#pragma mark -
#pragma mark StatusMenuItem actions

- (void)statusMenuItemWasClicked:(NSMenuItem *)sender{
	NSMenu *lastMenu = [sender menu];
	NSMenu *parent = [lastMenu supermenu];
	NSMutableArray *indexes = [NSMutableArray arrayWithObject:
		[NSNumber numberWithInt:[lastMenu indexOfItem:sender]]];
	while (parent){
		for (ZZConnection *conn in m_controller.connectedClients){
			if ([[[conn storageForPluginWithName:@"LoggerPlugin"] 
				objectForKey:@"MenuItem"] menu] == parent){
				[(AMFRemoteGateway *)conn.remote invokeRemoteService:@"MenuService" 
								 methodName:@"performClickOnMenuItemWithIndexPath" 
								  arguments:indexes, nil];
				return;
			}
		}
		
		for (int32_t i = 0; i < [[parent itemArray] count]; i++){
			NSMenuItem *item = [[parent itemArray] objectAtIndex:i];
			if ([item submenu] == lastMenu){
				[indexes insertObject:[NSNumber numberWithInt:i] atIndex:0];
			}
		}
		
		lastMenu = parent;
		parent = [lastMenu supermenu];
	}
}
@end