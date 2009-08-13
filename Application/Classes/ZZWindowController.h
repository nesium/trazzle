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

@protocol TrazzleTabViewDelegate;

@interface ZZWindowController : NSWindowController 
{
	IBOutlet PSMTabBarControl *m_tabBar;
	IBOutlet NSTabView *m_tabView;
	NSMutableArray *m_delegates;
	BOOL m_windowIsReady;
	BOOL m_windowWasVisible;
}
- (void)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate;
- (void)bringWindowToTop;
- (void)setWindowIsFloating:(BOOL)bFlag;
@end