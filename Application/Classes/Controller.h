//
//  DocumentController.h
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"
#import "PlugInController.h"
#import "AbstractPlugin.h"

#define SUPPORT_PATH @"~/Library/Application Support/Trazzle"

@interface Controller : NSObject
{
	NSMutableArray *m_loadedPlugins;
	WindowController *m_windowController;
	PlugInController *m_pluginController;
}

@end