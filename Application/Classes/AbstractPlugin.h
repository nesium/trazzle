//
//  AbstractPlugin.h
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlugInController.h"

@class PlugInController;

@interface AbstractPlugin : NSObject 
{
	PlugInController *plugInController;
}

@property (nonatomic, assign) PlugInController *plugInController;

@end