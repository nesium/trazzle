//
//  PMPerformanceMonitorPlugin.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZTrazzlePlugIn.h"
#import "PMMainWindowController.h"


@interface PMPerformanceMonitorPlugin : NSObject <ZZTrazzlePlugIn>{
	ZZPlugInController *m_controller;
	PMMainWindowController *m_windowController;
}

@end