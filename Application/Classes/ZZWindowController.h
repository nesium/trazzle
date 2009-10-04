//
//  WindowController.h
//  Trazzle
//
//  Created by Marc Bauer on 03.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import "ZZTabStyle.h"
#import "ZZWindow.h"

@protocol TrazzleTabViewDelegate;

@interface ZZWindowController : NSWindowController 
{
	id m_delegate;
	IBOutlet PSMTabBarControl *m_tabBar;
	IBOutlet NSTabView *m_tabView;
	NSMutableArray *m_delegates;
	BOOL m_windowIsReady;
	BOOL m_windowWasVisible;
	NSTabViewItem *m_lastSelectedTabViewItem;
}
- (id)initWithWindowNibName:(NSString *)windowNibName delegate:(id)delegate;

- (id)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate;
- (void)bringWindowToTop;
- (void)setWindowIsFloating:(BOOL)bFlag;
- (void)selectTabItemWithDelegate:(id<TrazzleTabViewDelegate>)aDelegate;
@end

@interface NSObject (ZZWindowControllerDelegate)
- (void)windowController:(ZZWindowController *)controller 
	didSelectTabViewDelegate:(id <TrazzleTabViewDelegate>)aDelegate;
- (void)windowController:(ZZWindowController *)controller
	didCloseTabViewDelegate:(id <TrazzleTabViewDelegate>)aDelegate;
@end