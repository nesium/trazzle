//
//  LoggingViewController.h
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AbstractMessage.h"

@class WebViewController;

@interface LoggingViewController : NSViewController 
{
	IBOutlet WebView *m_webView;
	IBOutlet NSView *m_searchBar;
	IBOutlet NSSearchField *m_searchField;
	
	id m_delegate;
	BOOL m_webViewReady;
	NSTimer *m_sendTimer;
	NSMutableArray *m_buffer;
}
@property (nonatomic, assign) id delegate;

- (void)loadURL:(NSURL *)url;
- (void)sendMessage:(AbstractMessage *)message;
- (void)sendMessages:(NSArray *)messages;
- (void)hideMessagesWithIndexes:(NSArray *)indexes;
- (void)showMessagesWithIndexes:(NSArray *)indexes;
- (void)clearAllMessages;
@end


@interface NSObject (LoggingViewControllerDelegate)
- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
	messageAtIndex:(uint32_t)index;
- (void)loggingViewControllerWebViewIsReady:(LoggingViewController *)controller;
@end