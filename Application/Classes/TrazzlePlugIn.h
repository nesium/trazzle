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
@end

@protocol TrazzleTabViewDelegate
@optional
- (BOOL)receivedKeyDown:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
- (BOOL)receivedKeyUp:(NSEvent *)event inTabWithIdentifier:(NSString *)identifier;
@required
- (NSString *)titleForTabWithIdentifier:(NSString *)identifier;
@end