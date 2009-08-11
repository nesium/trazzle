/*
 *  TrazzlePlugIn.h
 *  Trazzle
 *
 *  Created by Marc Bauer on 15.11.08.
 *  Copyright 2008 nesiumdotcom. All rights reserved.
 *
 */

#import "PlugInController.h"
#import <Foundation/NSKeyValueObserving.h>

@class PlugInController;

@protocol TrazzlePlugIn
- (id)initWithPlugInController:(PlugInController *)controller;
@end

@protocol TrazzleTabViewDelegate
@optional
- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
@required
- (NSString *)titleForTabWithIdentifier:(NSString *)identifier;
@end