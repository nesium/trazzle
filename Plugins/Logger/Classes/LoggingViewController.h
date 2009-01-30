//
//  LoggingViewController.h
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface LoggingViewController : NSViewController 
{
	IBOutlet WebView *m_webView;
	IBOutlet NSSearchField *m_searchField;
	IBOutlet NSView *m_searchBar;
}

@end
