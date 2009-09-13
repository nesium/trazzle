//
//  PMMainWindowController.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMStatsViewLayer.h"
#import "PMStatsSessionViewLayer.h"
#import "AGProcess.h"


@interface PMMainWindowController : NSWindowController
{
	NSTimer *m_redrawTimer;
	NSMutableArray *m_layers;
}
@end