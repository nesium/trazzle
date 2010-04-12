//
//  LoggingViewController.m
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggingViewController.h"

@interface LoggingViewController (Private)
- (void)_setSearchBarVisible:(BOOL)isVisible;
- (void)_initTimer;
- (void)_invalidateTimer;
- (void)_flushBuffer:(NSTimer *)timer;
@end

@implementation LoggingViewController

@synthesize delegate=m_delegate;

#pragma mark -
#pragma mark Initialization & Deallocation

- (void)awakeFromNib{
	m_webViewReady = NO;
	m_searchBarIsVisible = NO;
	m_buffer = [[NSMutableArray alloc] init];
	
	[m_webView setFrameLoadDelegate:self];
	[m_webView setPolicyDelegate:self];
	[m_webView setUIDelegate:self];
		
	[self loadURL:[NSURL URLWithString:[[[NSBundle bundleForClass:[self class]] 
		pathForResource:@"theme" ofType:@"html"] 
		stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	[self setNextResponder:[m_webView nextResponder]];
	[m_webView setNextResponder:self];
}

- (void)dealloc{
	[m_webView setFrameLoadDelegate:nil];
	[m_webView setPolicyDelegate:nil];
	[m_webView setUIDelegate:nil];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)loadURL:(NSURL *)url{
	m_webViewReady = NO;
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[[m_webView mainFrame] loadRequest:request];
}

- (void)sendMessage:(AbstractMessage *)message{
	[m_buffer addObject:message];
	[self _initTimer];
}

- (void)sendMessages:(NSArray *)messages{
	[m_buffer addObjectsFromArray:messages];
	[self _initTimer];
}

- (void)hideMessagesWithIndexes:(NSArray *)indexes{
	WebScriptObject *window = [m_webView windowScriptObject];	
	[window callWebScriptMethod:@"hideMessagesWithIndexes" 
		withArguments:[NSArray arrayWithObject:indexes]];
}

- (void)showMessagesWithIndexes:(NSArray *)indexes{
	WebScriptObject *window = [m_webView windowScriptObject];	
	[window callWebScriptMethod:@"showMessagesWithIndexes" 
		withArguments:[NSArray arrayWithObject:indexes]];
}

- (void)removeMessagesWithIndexes:(NSArray *)indexes{
	WebScriptObject *window = [m_webView windowScriptObject];
	[window callWebScriptMethod:@"removeMessagesWithIndexes" 
		withArguments:[NSArray arrayWithObject:indexes]];
}

- (void)clearAllMessages{
	[m_buffer removeAllObjects];
	//[m_systemMessagesBuffer removeAllObjects];
	WebScriptObject *window = [m_webView windowScriptObject];
	[window callWebScriptMethod:@"clearAllMessages" withArguments:nil];
}



#pragma mark -
#pragma mark First responder methods

- (void)performFindAction:(id)sender{
	[self _setSearchBarVisible:YES];
}

- (void)performFindNextAction:(id)sender{
	[m_webView searchFor:[m_searchField stringValue] direction:YES caseSensitive:NO wrap:YES];
}

- (void)performFindPreviousAction:(id)sender{
	[m_webView searchFor:[m_searchField stringValue] direction:NO caseSensitive:NO wrap:YES];
}



#pragma mark -
#pragma mark IB Actions

- (IBAction)hideSearchBar:(id)sender{
	[self _setSearchBarVisible:NO];
}



#pragma mark -
#pragma mark Private methods

- (void)_setSearchBarVisible:(BOOL)isVisible{
	if (m_searchBarIsVisible == isVisible){
		[[[self view] window] makeFirstResponder:(isVisible 
			? m_searchField 
			: (NSResponder *)m_webView)];
		return;
	}
	
	NSRect searchBarFrame = [m_searchBar bounds];
	searchBarFrame.size.width = [[self view] bounds].size.width;
	searchBarFrame.origin = (NSPoint){0, [[self view] bounds].size.height};
	NSRect newWebViewFrame = [[self view] bounds];
	
	if (isVisible){
		[[self view] addSubview:m_searchBar];
		[m_searchBar setFrame:searchBarFrame];
		searchBarFrame.origin = (NSPoint){0, [[self view] bounds].size.height - 
			searchBarFrame.size.height};
		
		newWebViewFrame.size.height -= searchBarFrame.size.height;
	}
	
	[NSAnimationContext beginGrouping];
	[[m_searchBar animator] setFrame:searchBarFrame];
	[[m_webView animator] setFrame:newWebViewFrame];
	[NSAnimationContext endGrouping];
	
	[[[self view] window] makeFirstResponder:(isVisible 
		? m_searchField 
		: (NSResponder *)m_webView)];
	
	m_searchBarIsVisible = isVisible;
}

- (void)_markWebViewReady{
	m_webViewReady = YES;
	if ([m_delegate respondsToSelector:@selector(loggingViewControllerWebViewIsReady:)])
		[m_delegate loggingViewControllerWebViewIsReady:self];
}

- (void)_initTimer{
	if (m_sendTimer != nil)
		return;
	m_sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/35.0 target:self 
		selector:@selector(_flushBuffer:) userInfo:nil repeats:YES];
}

- (void)_invalidateTimer{
	if ([m_buffer count])
		return;
	[m_sendTimer invalidate];
	m_sendTimer = nil;
}

- (void)_flushBuffer:(NSTimer *)timer{
	if (!m_webViewReady || ![m_buffer count]){
		[self _invalidateTimer];
		return;
	}
	WebScriptObject *window = [m_webView windowScriptObject];
	[window callWebScriptMethod:@"appendMessages" 
		withArguments:[NSArray arrayWithObject:m_buffer]];
	[m_buffer removeAllObjects];
}



#pragma mark -
#pragma mark WebView delegate methods

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
	[self performSelector:@selector(_markWebViewReady) withObject:nil afterDelay:0.0];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
	request:(NSURLRequest *)request frame:(WebFrame *)frame 
	decisionListener:(id<WebPolicyDecisionListener>)listener{
    int actionKey = [[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
    if (actionKey == WebNavigationTypeOther) 
		[listener use];
	else{
		NSURL *url = [actionInformation objectForKey:WebActionOriginalURLKey];
		//Ignore file URLs, but open anything else
		if (![url isFileURL])
			[[NSWorkspace sharedWorkspace] openURL:url];
		[listener ignore];
    }
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
	defaultMenuItems:(NSArray *)defaultMenuItems{
	// show custom contextmenu
	return nil;
}

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject{
	// window script object available
	[windowScriptObject setValue:self forKey:@"TrazzleBridge"];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message{
	// show alert, or not
	NSLog(@"alert: %@", message);
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary{
	NSLog(@"error: %@", dictionary);
}

- (unsigned)webView:(WebView *)sender 
	dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo{
	return WebDragDestinationActionNone;
}



#pragma mark -
#pragma mark WebScriptObject methods

- (AbstractMessage *)messageWithIndex:(NSNumber *)index{
	if ([m_delegate respondsToSelector:@selector(loggingViewController:messageWithIndex:)]){
		return [m_delegate loggingViewController:self messageWithIndex:[index intValue]];
	}
	return nil;
}

- (void)log:(NSString *)message{
	NSLog(@"Theme Log: %@", message);
}

- (BOOL)textMateLinksEnabled{
	return [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		valueForKey:kShowTextMateLinks] boolValue];
}

- (void)showDetailForMessageWithIndex:(NSNumber *)index{
	if ([m_delegate respondsToSelector:
		@selector(loggingViewController:showDetailForMessageWithIndex:)]){
		[m_delegate loggingViewController:self showDetailForMessageWithIndex:[index intValue]];
	}
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel{
	return !(sel == @selector(messageWithIndex:) || sel == @selector(log:) || 
		sel == @selector(textMateLinksEnabled) || sel == @selector(showDetailForMessageWithIndex:));
}

+ (NSString *)webScriptNameForSelector:(SEL)sel{
	if (sel == @selector(messageWithIndex:))
		return @"messageWithIndex";
	else if (sel == @selector(log:))
		return @"log";
	else if (sel == @selector(showDetailForMessageWithIndex:))
		return @"showDetailForMessageWithIndex";
    return nil;
}
@end