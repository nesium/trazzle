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
- (void)_updateMixedStatus;
@end


@implementation LPSession

@synthesize tabTitle=m_tabTitle, 
			sessionName=m_sessionName, 
			isReady=m_isReady, 
			filterModel=m_filterModel, 
			swfURL=m_swfURL, 
			isDisconnected=m_isDisconnected, 
			icon=m_icon, 
			representedObjects=m_representedObjects, 
			delegate=m_delegate, 
			isPristine=m_isPristine, 
			isMixed=m_isMixed;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(ZZPlugInController *)aController{
	if (self = [super init]){
		m_controller = aController;
		
		m_isReady = NO;
		m_isActive = NO;
		m_isPristine = YES;
		m_isDisconnected = YES;
		m_isMixed = NO;
		m_representedObjects = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsZeroingWeakMemory];
		
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

- (void)dealloc{
	[m_messageModel release];
	[m_filterModel release];
	[m_loggingViewController release];
	[m_tabTitle release];
	[m_sessionName release];
	[m_swfURL release];
	[m_icon release];
	[m_representedObjects release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)handleMessage:(AbstractMessage *)msg{
	[m_messageModel addMessage:msg];
	[m_loggingViewController sendMessage:msg];
}

- (void)addConnection:(ZZConnection *)connection{
	[m_representedObjects addPointer:connection];
	[self _updateMixedStatus];
	self.isDisconnected = NO;
	self.isPristine = NO;
	self.sessionName = connection.applicationName;
	self.swfURL = connection.swfURL;
	[self _updateTabTitle];
	
	NSObject *defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
	BOOL clearMessagesOnNewConnection = 
		[[defaults valueForKey:kClearMessagesOnNewConnection] boolValue];
	BOOL clearFlashLogMessagesOnNewConnection = 
		[[defaults valueForKey:kClearFlashLogMessagesOnNewConnection] boolValue];
	
	if (clearMessagesOnNewConnection && clearFlashLogMessagesOnNewConnection){
		[m_messageModel clearAllMessages];
		[m_loggingViewController clearAllMessages];
	}
	else if (clearMessagesOnNewConnection)
		[m_messageModel clearLogMessages];
	else if ( clearFlashLogMessagesOnNewConnection)
		[m_messageModel clearFlashLogMessages];
}

- (void)removeConnection:(ZZConnection *)connection{
	[m_representedObjects aa_removePointer:connection];
	self.isDisconnected = [m_representedObjects count] == 0;
	[self _updateMixedStatus];
}

- (BOOL)containsConnection:(ZZConnection *)connection{
	return [m_representedObjects aa_containsPointer:connection];
}

- (void)setIsDisconnected:(BOOL)bFlag{
	if (m_isDisconnected == bFlag) return;
	m_isDisconnected = bFlag;
	[self _updateIcon];
}

- (NSTimeInterval)lastLogMessageTimestamp{
	return [m_messageModel lastLogMessageTimestamp];
}



#pragma mark -
#pragma mark TrazzleTabViewDelegate methods

- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier 
	window:(NSWindow *)window{
	if ([[window firstResponder] isKindOfClass:[NSTextView class]]) return NO;
	return [event keyCode] == 51 || [event keyCode] == 117;
}

- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier 
	window:(NSWindow *)window{
	if ([[window firstResponder] isKindOfClass:[NSTextView class]]) return NO;
	if ([event keyCode] == 51 || [event keyCode] == 117){
		[m_messageModel clearAllMessages];
		[m_loggingViewController clearAllMessages];
	}
	return YES;
}

- (NSString *)titleForTabWithIdentifier:(NSString *)identifier{
	return m_tabTitle;
}

- (void)didBecomeInactive{
	m_isActive = NO;
	[self _updateIcon];
}

- (void)didBecomeActive{
	m_isActive = YES;
	[self _updateIcon];
}



#pragma mark -
#pragma mark KVO notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context{
	if (object == m_filterModel){
		[self _updateTabTitle];
		[m_messageModel setFilter:m_filterModel.filteringIsEnabled 
			? m_filterModel.activeFilter
			: nil];
	}
}



#pragma mark -
#pragma mark Private methods

- (void)_updateTabTitle{
	NSString *sessionName = m_isMixed ? @"Mixed Session" : m_sessionName;
	self.tabTitle = [NSString stringWithFormat:@"%@%@", sessionName, 
		m_filterModel.filteringIsEnabled ? @"*" : @""];
}

- (void)_updateIcon{
	if (!m_isDisconnected || m_isPristine)
		self.icon = nil;
	else{
		NSString *state = m_isActive ? @"on" : @"off";
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle bundleForClass:[self class]] pathForImageResource:
				[NSString stringWithFormat:@"tab_%@_icon_disconnected", state]]];
		self.icon = image;
		[image release];
	}
}

- (void)_updateMixedStatus{
	if ([m_representedObjects count] == 0){
		self.isMixed = NO;
		return;
	}
	NSURL *baseURL = [(ZZConnection *)[m_representedObjects pointerAtIndex:0] swfURL];
	for (int i = 1; i < [m_representedObjects count]; i++){
		if (![[(ZZConnection *)[m_representedObjects pointerAtIndex:i] swfURL] isEqual:baseURL]){
			self.isMixed = YES;
			return;
		}
	}
	self.isMixed = NO;
}



#pragma mark -
#pragma mark LoggingViewController delegate methods

- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
	messageWithIndex:(uint32_t)index{
	return [m_messageModel messageWithIndex:index];
}

- (void)loggingViewControllerWebViewIsReady:(LoggingViewController *)controller{
	if (!m_isReady) self.isReady = YES;
}



#pragma mark -
#pragma mark MessageModel delegate methods

- (void)messageModel:(LPMessageModel *)model didHideMessagesWithIndexes:(NSArray *)indexes{
	[m_loggingViewController hideMessagesWithIndexes:indexes];
}

- (void)messageModel:(LPMessageModel *)model didShowMessagesWithIndexes:(NSArray *)indexes{
	[m_loggingViewController showMessagesWithIndexes:indexes];
}

- (void)messageModel:(LPMessageModel *)model didRemoveMessagesWithIndexes:(NSArray *)indexes{
	[m_loggingViewController removeMessagesWithIndexes:indexes];
}
@end