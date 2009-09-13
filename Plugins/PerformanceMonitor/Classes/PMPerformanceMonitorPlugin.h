//
//  PMPerformanceMonitorPlugin.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrazzlePlugIn.h"
#import "PMMainWindowController.h"


@interface PMPerformanceMonitorPlugin : NSObject <TrazzlePlugIn>
{
	PlugInController *m_controller;
	PMMainWindowController *m_windowController;
}

@end