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

@class PlugInController, ZZConnection;

@protocol TrazzlePlugIn
@required
- (id)initWithPlugInController:(PlugInController *)controller;
@optional
- (void)trazzleDidOpenConnection:(ZZConnection *)conn;
- (void)trazzleDidCloseConnection:(ZZConnection *)conn;
- (void)trazzleDidReceiveSignatureForConnection:(ZZConnection *)conn;
// triggered by legacy connections
- (void)trazzleDidReceiveMessage:(NSString *)msg forConnection:(ZZConnection *)conn;
- (void)prefPane:(NSViewController **)viewController icon:(NSImage **)icon;
@end

@protocol TrazzleTabViewDelegate
@optional
- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
@required
- (NSString *)titleForTabWithIdentifier:(NSString *)identifier;
@end