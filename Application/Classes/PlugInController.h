//
//  PlugInController.h
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"


@interface PlugInController : NSObject 
{
}

- (id)initWithPlugInBundle:(NSBundle *)bundle windowController:(WindowController *)controller;

- (void)addTabWithIdentifier:(id)ident title:(NSString *)title view:(NSView *)view;
- (void)addStatusMenuItem:(NSMenuItem *)item;
- (void)removeStatusMenuItem:(NSMenuItem *)item;

@end