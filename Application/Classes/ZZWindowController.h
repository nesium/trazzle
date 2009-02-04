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


@interface ZZWindowController : NSWindowController 
{
	IBOutlet PSMTabBarControl *m_tabBar;
	IBOutlet NSTabView *m_tabView;
}

- (void)addTabWithIdentifier:(id)ident title:(NSString *)title view:(NSView *)view;

@end