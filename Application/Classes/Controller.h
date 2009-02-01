//
//  DocumentController.h
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/objc-runtime.h>
#import "WindowController.h"
#import "PlugInController.h"
#import "TrazzlePlugIn.h"

#define SUPPORT_PATH @"~/Library/Application Support/Trazzle"

@interface Controller : NSObject
{
	NSMutableArray *m_loadedPlugins;
	NSMutableArray *m_plugInControllers;
	WindowController *m_windowController;
}

@end