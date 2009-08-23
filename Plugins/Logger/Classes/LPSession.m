//
//  LPSession.m
//  Logger
//
//  Created by Marc Bauer on 21.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPSession.h"

@interface LPSession (Private)
- (void)_updateTabTitle;
- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client;
- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client;
@end


@implementation LPSession

@synthesize tabTitle=m_tabTitle, 
			sessionName=m_sessionName, 
			isReady=m_isReady, 
			filterModel=m_filterModel;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_controller = aController;
		
		m_isReady = NO;
		
		m_filterModel = [[LPFilterModel alloc] init];
		
		m_messageModel = [[MessageModel alloc] init];
		m_messageModel.delegate = self;
				
		[m_messageModel bind:@"showsFlashLogMessages" toObject:m_filterModel 
			withKeyPath:@"showsFlashLogMessages" options:0];
		[m_messageModel bind:@"filter" toObject:m_filterModel 
			withKeyPath:@"activeFilter" options:0];
		m_messageModel.showsFlashLogMessages = m_filterModel.showsFlashLogMessages;
		m_messageModel.filter = m_filterModel.activeFilter;
		
		[m_filterModel addObserver:self forKeyPath:@"filteringIsEnabled" options:0 context:NULL];
		
		self.sessionName = @"New Session";
		[self _updateTabTitle];
		
		// display viewcontroller
		m_loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LogWindow" 
			bundle:[NSBundle bundleForClass:[self class]]];
		m_loggingViewController.delegate = self;
		[m_controller addTabWithIdentifier:@"Foo" view:[m_loggingViewController view] delegate:self];
	}
	return self;
}

- (void)dealloc
{
	[m_messageModel release];
	[m_filterModel release];
	[m_loggingViewController release];
	[m_tabTitle release];
	[m_sessionName release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)handleFlashlogMessage:(AbstractMessage *)msg
{
	[self _handleMessage:msg fromClient:nil];
}

- (void)addRemoteGateway:(LPRemoteGateway *)gateway
{
	[m_messageModel clearAllMessages];
	[m_loggingViewController clearAllMessages];
	gateway.delegate = self;
}

- (void)addLoggingClient:(LoggingClient *)client
{
	[m_messageModel clearAllMessages];
	[m_loggingViewController clearAllMessages];
	client.delegate = self;
}



#pragma mark -
#pragma mark TrazzleTabViewDelegate methods

- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier 
				 window:(NSWindow *)window
{
	if ([[window firstResponder] isKindOfClass:[NSTextView class]]) return NO;
	return [event keyCode] == 51 || [event keyCode] == 117;
}

- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier 
			   window:(NSWindow *)window
{
	if ([[window firstResponder] isKindOfClass:[NSTextView class]]) return NO;
	if ([event keyCode] == 51 || [event keyCode] == 117)
	{
		[m_messageModel clearAllMessages];
		[m_loggingViewController clearAllMessages];
	}
	return YES;
}

- (NSString *)titleForTabWithIdentifier:(NSString *)identifier
{
	return m_tabTitle;
}



#pragma mark -
#pragma mark KVO notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context
{
	if (object == m_filterModel && [keyPath isEqualToString:@"filteringIsEnabled"])
	{
		[self _updateTabTitle];
		[m_messageModel setFilter:m_filterModel.filteringIsEnabled 
			? m_filterModel.activeFilter
			: nil];
	}
}



#pragma mark -
#pragma mark Private methods

- (void)_updateTabTitle
{
	self.tabTitle = [NSString stringWithFormat:@"%@%@", m_sessionName, 
		m_filterModel.filteringIsEnabled ? @"*" : @""];
}

- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client
{
	if (msg.messageType == kLPMessageTypePolicyRequest)
	{
		[client sendString:@"<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0"];
		return;
	}
	if ([m_messageModel numberOfMessages] == 0)
		[m_controller bringWindowToTop];
	[m_messageModel addMessage:msg];
	[m_loggingViewController sendMessage:msg];
}

- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client
{
	if (msg.type == kCommandActionTypeStartFileMonitoring)
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



#pragma mark -
#pragma mark MessageParser delegate methods

- (void)parser:(MessageParser *)parser didParseMenuItem:(NSMenuItem *)menuItem
{
	[menuItem setTarget:self];
	[menuItem setAction:@selector(statusMenuItemWasClicked:)];
}



#pragma mark -
#pragma mark LoggingService Delegate methods

- (void)loggingService:(LoggingService *)service didReceiveLogMessage:(LogMessage *)message 
		   fromGateway:(AMFRemoteGateway *)gateway
{
	[self _handleMessage:message fromClient:nil];
}

- (void)loggingService:(LoggingService *)service didReceiveConnectionParams:(NSDictionary *)params 
		   fromGateway:(AMFRemoteGateway *)gateway
{	
	self.sessionName = [params objectForKey:@"applicationName"];
	[(LPRemoteGateway *)gateway setConnectionParams:params];
	[self _updateTabTitle];
}

- (void)loggingService:(LoggingService *)service didReceivePNG:(NSString *)path withSize:(NSSize)size
		   fromGateway:(AMFRemoteGateway *)gateway
{
	AbstractMessage *msg = [[AbstractMessage alloc] init];
	msg.message = [NSString stringWithFormat:@"<img src='%@' width='%d' height='%d' />", path, 
				   (int)size.width, (int)size.height];
	[self _handleMessage:msg fromClient:nil];
	[msg release];
}



#pragma mark -
#pragma mark MenuService Delegate methods

- (void)menuService:(MenuService *)service didReceiveMenu:(NSMenu *)menu 
		fromGateway:(AMFRemoteGateway *)gateway
{
	LPRemoteGateway *remote = (LPRemoteGateway *)gateway;
	if (remote.menuItem)
	{
		[m_controller removeStatusMenuItem:remote.menuItem];
		remote.menuItem = nil;
	}
	
	NSMenuItem *item = [[NSMenuItem alloc] init];
	[item setTitle:m_sessionName];
	[item setSubmenu:menu];
	remote.menuItem = item;
	[m_controller addStatusMenuItem:item];
	[item release];
}



#pragma mark -
#pragma mark LoggingViewController delegate methods

- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
							messageAtIndex:(uint32_t)index
{
	return [m_messageModel messageAtIndex:index];
}

- (void)loggingViewControllerWebViewIsReady:(LoggingViewController *)controller
{
	if (!m_isReady) self.isReady = YES;
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

@end