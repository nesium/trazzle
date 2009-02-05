//
//  PlugInController.h
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZWindowController.h"


@interface PlugInController : NSObject 
{
}

- (id)initWithPlugInBundle:(NSBundle *)bundle windowController:(ZZWindowController *)controller;

- (void)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate;
- (void)addStatusMenuItem:(NSMenuItem *)item;
- (void)removeStatusMenuItem:(NSMenuItem *)item;

@end