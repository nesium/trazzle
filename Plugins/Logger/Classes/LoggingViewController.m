//
//  LoggingViewController.m
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggingViewController.h"

@interface LoggingViewController (Private)
- (void)_initTimer;
- (void)_invalidateTimer;
- (void)_flushBuffer:(NSTimer *)timer;
@end

@implementation LoggingViewController

@synthesize delegate=m_delegate;

#pragma mark -
#pragma mark Initialization & Deallocation

- (void)awakeFromNib
{
	m_webViewReady = NO;
	m_buffer = [[NSMutableArray alloc] init];
	
	[m_webView setFrameLoadDelegate:self];
	[m_webView setPolicyDelegate:self];
	[m_webView setUIDelegate:self];
		
	[self loadURL:[NSURL URLWithString:[[[NSBundle bundleForClass:[self class]] 
		pathForResource:@"theme" ofType:@"html"] 
		stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)dealloc
{
	[m_webView setFrameLoadDelegate:nil];
	[m_webView setPolicyDelegate:nil];
	[m_webView setUIDelegate:nil];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)loadURL:(NSURL *)url
{
	m_webViewReady = NO;
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[[m_webView mainFrame] loadRequest:request];
}

- (void)sendMessage:(AbstractMessage *)message
{
	[m_buffer addObject:message];
	[self _initTimer];
}

- (void)sendMessages:(NSArray *)messages
{
	[m_buffer addObjectsFromArray:messages];
	[self _initTimer];
}

- (void)hideMessagesWithIndexes:(NSArray *)indexes
{
	WebScriptObject *window = [m_webView windowScriptObject];	
	[window callWebScriptMethod:@"hideMessagesWithIndexes" 
		withArguments:[NSArray arrayWithObject:indexes]];
}

- (void)showMessagesWithIndexes:(NSArray *)indexes
{
	WebScriptObject *window = [m_webView windowScriptObject];	
	[window callWebScriptMethod:@"showMessagesWithIndexes" 
		withArguments:[NSArray arrayWithObject:indexes]];
}

- (void)clearAllMessages
{
	[m_buffer removeAllObjects];
	//[m_systemMessagesBuffer removeAllObjects];
	WebScriptObject *window = [m_webView windowScriptObject];
	[window callWebScriptMethod:@"clearAllMessages" withArguments:nil];
}



#pragma mark -
#pragma mark Private methods

- (void)_markWebViewReady
{
	m_webViewReady = YES;
	if ([m_delegate respondsToSelector:@selector(loggingViewControllerWebViewIsReady:)])
		[m_delegate loggingViewControllerWebViewIsReady:self];
}

- (void)_initTimer
{
	if (m_sendTimer != nil)
	{
		return;
	}
	m_sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/35.0 target:self 
		selector:@selector(_flushBuffer:) userInfo:nil repeats:YES];
}

- (void)_invalidateTimer
{
	if ([m_buffer count])
	{
		return;
	}
	[m_sendTimer invalidate];
	m_sendTimer = nil;
}

- (void)_flushBuffer:(NSTimer *)timer
{
	if (!m_webViewReady || ![m_buffer count])
	{
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

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	[self performSelector:@selector(_markWebViewReady) withObject:nil afterDelay:0.0];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
	request:(NSURLRequest *)request frame:(WebFrame *)frame 
	decisionListener:(id<WebPolicyDecisionListener>)listener
{
    int actionKey = [[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
    if (actionKey == WebNavigationTypeOther) 
	{
		[listener use];
    } 
	else 
	{
		NSURL *url = [actionInformation objectForKey:WebActionOriginalURLKey];
		//Ignore file URLs, but open anything else
		if (![url isFileURL]) 
		{
			[[NSWorkspace sharedWorkspace] openURL:url];
		}
		[listener ignore];
    }
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
	defaultMenuItems:(NSArray *)defaultMenuItems
{
	// show custom contextmenu
	return defaultMenuItems;
}

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject
{
	// window script object available
	[windowScriptObject setValue:self forKey:@"TrazzleBridge"];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message
{
	// show alert, or not
	NSLog(@"alert: %@", message);
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
	NSLog(@"error: %@", dictionary);
}



#pragma mark -
#pragma mark WebScriptObject methods

- (AbstractMessage *)messageAtIndex:(NSNumber *)index
{
	if ([m_delegate respondsToSelector:@selector(loggingViewController:messageAtIndex:)])
	{
		return [m_delegate loggingViewController:self messageAtIndex:[index intValue]];
	}
	return nil;
}

- (void)log:(NSString *)message
{
	NSLog(@"Theme Log: %@", message);
}

- (BOOL)textMateLinksEnabled
{
	return YES;
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
	return !(sel == @selector(messageAtIndex:) || sel == @selector(log:) || 
		sel == @selector(textMateLinksEnabled));
}

+ (NSString *)webScriptNameForSelector:(SEL)sel
{
	if (sel == @selector(messageAtIndex:))
	{
		return @"messageAtIndex";
	}
	else if (sel == @selector(log:))
	{
		return @"log";
	}
    return nil;
}

@end