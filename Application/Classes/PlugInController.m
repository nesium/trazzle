//
//  PlugInController.m
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "PlugInController.h"
#import "WindowController.h"


WindowController *m_windowController;

@implementation PlugInController

- (void)setWindowController:(WindowController *)winController
{
	m_windowController = winController;
}



#pragma mark -
#pragma mark Public methods

- (void)addTabWithIdentifier:(id)ident title:(NSString *)title view:(NSView *)view
{
	NSLog(@"hello");
	[m_windowController addTabWithIdentifier:ident title:title view:view];
}

@end