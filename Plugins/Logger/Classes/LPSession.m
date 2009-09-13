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
- (void)_updateIcon;
//- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client;
//- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client;
@end


@implementation LPSession

@synthesize tabTitle=m_tabTitle, 
			sessionName=m_sessionName, 
			isReady=m_isReady, 
			filterModel=m_filterModel, 
			swfURL=m_swfURL, 
			isDisconnected=m_isDisconnected, 
			icon=m_icon, 
			representedObject=m_representedObject, 
			delegate=m_delegate;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_controller = aController;
		
		m_isReady = NO;
		m_isActive = NO;
		m_isDisconnected = NO;
		
		m_filterModel = [[LPFilterModel alloc] init];
		
		m_messageModel = [[LPMessageModel alloc] init];
		m_messageModel.delegate = self;
				
		[m_messageModel bind:@"showsFlashLogMessages" toObject:m_filterModel 
			withKeyPath:@"showsFlashLogMessages" options:0];
		m_messageModel.showsFlashLogMessages = m_filterModel.showsFlashLogMessages;
		m_messageModel.filter = m_filterModel.filteringIsEnabled ? m_filterModel.activeFilter : nil;
		
		[m_filterModel addObserver:self forKeyPath:@"activeFilter" options:0 context:NULL];
		[m_filterModel addObserver:self forKeyPath:@"filteringIsEnabled" options:0 context:NULL];
		
		self.sessionName = @"New Session";
		[self _updateTabTitle];
		
		// display viewcontroller
		m_loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LogWindow" 
			bundle:[NSBundle bundleForClass:[self class]]];
		m_loggingViewController.delegate = self;
		m_tab = [m_controller addTabWithIdentifier:@"Foo" view:[m_loggingViewController view] 
			delegate:self];
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
	[m_swfURL release];
	[m_icon release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)handleMessage:(AbstractMessage *)msg
{
	if ([m_messageModel numberOfMessages] == 0)
		[m_controller bringWindowToTop];
	[m_messageModel addMessage:msg];
	[m_loggingViewController sendMessage:msg];
}

- (void)addConnection:(ZZConnection *)connection
{
	[m_messageModel clearAllMessages];
	[m_loggingViewController clearAllMessages];
}

- (void)setSessionName:(NSString *)aName
{
	[self willChangeValueForKey:@"sessionName"];
	[aName retain];
	[m_sessionName release];
	m_sessionName = aName;
	[self didChangeValueForKey:@"sessionName"];
	[self _updateTabTitle];
}

- (void)setIsDisconnected:(BOOL)bFlag
{
	if (m_isDisconnected == bFlag) return;
	m_isDisconnected = bFlag;
	[self _updateIcon];
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

- (void)didBecomeInactive
{
	m_isActive = NO;
	[self _updateIcon];
}

- (void)didBecomeActive
{
	m_isActive = YES;
	[self _updateIcon];
}



#pragma mark -
#pragma mark KVO notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context
{
	if (object == m_filterModel)
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

- (void)_updateIcon
{
	if (!m_isDisconnected)
		self.icon = nil;
	else
	{
		NSString *state = m_isActive ? @"on" : @"off";
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle bundleForClass:[self class]] pathForImageResource:
				[NSString stringWithFormat:@"tab_%@_icon_disconnected", state]]];
		self.icon = image;
		[image release];
	}
}

//
//- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client
//{
//	if (msg.type == kCommandActionTypeStartFileMonitoring)
//	{
//		[[FileMonitor sharedMonitor] addObserver:client 
//			forFileAtPath:[msg.attributes objectForKey:@"path"]];
//	}
//	else if (msg.type == kCommandActionTypeStopFileMonitoring)
//	{
//		[[FileMonitor sharedMonitor] removeObserver:client 
//			forFileAtPath:[msg.attributes objectForKey:@"path"]];
//	}
//}



//#pragma mark -
//#pragma mark LoggingClient delegate methods
//
//- (void)client:(LoggingClient *)client didReceiveMessage:(NSString *)message
//{
//	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message delegate:self];
//	AbstractMessage *msg = (AbstractMessage *)[[parser data] objectAtIndex:0];
//	
//	if (msg.messageType == kLPMessageTypeCommand)
//		[self _handleCommandMessage:(CommandMessage *)msg fromClient:client];
//	else
//		[self _handleMessage:msg fromClient:client];
//	[parser release];
//}



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

- (void)messageModel:(LPMessageModel *)model didHideMessagesWithIndexes:(NSArray *)indexes
{
	[m_loggingViewController hideMessagesWithIndexes:indexes];
}

- (void)messageModel:(LPMessageModel *)model didShowMessagesWithIndexes:(NSArray *)indexes
{
	[m_loggingViewController showMessagesWithIndexes:indexes];
}

@end