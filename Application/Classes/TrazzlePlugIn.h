/*
 *  TrazzlePlugInController.h
 *  Trazzle
 *
 *  Created by Marc Bauer on 15.11.08.
 *  Copyright 2008 nesiumdotcom. All rights reserved.
 *
 */

#import "PlugInController.h"

@class PlugInController;

@protocol TrazzlePlugIn
- (id)initWithPlugInController:(PlugInController *)controller;
@end