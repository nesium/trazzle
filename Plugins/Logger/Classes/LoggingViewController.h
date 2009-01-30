//
//  LoggingViewController.h
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "LogMessage.h"
#import "SystemMessage.h"

@class WebViewController;

@interface LoggingViewController : NSViewController 
{
	IBOutlet WebView *m_webView;
	IBOutlet NSView *m_searchBar;
	IBOutlet NSSearchField *m_searchField;
	
	BOOL m_webViewReady;
	NSTimer *m_sendTimer;
	NSMutableArray *m_buffer;
	NSMutableArray *m_systemMessagesBuffer;
}
- (void)loadURL:(NSURL *)url;
- (void)sendLogMessage:(LogMessage *)message;
- (void)sendLogMessages:(NSArray *)messages;
- (void)sendSystemMessage:(SystemMessage *)message;
- (void)hideMessagesWithIndexes:(NSArray *)indexes;
- (void)showMessagesWithIndexes:(NSArray *)indexes;
- (void)clearAllMessages;
@end



@interface TrazzleWindowScriptObject : NSObject 
{
}
- (LogMessage *)logMessageAtIndex:(NSNumber *)index;
@end