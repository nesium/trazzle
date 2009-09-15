//
//  PMMainWindowController.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PMStatsViewLayer.h"
#import "PMStatsSessionViewLayer.h"
#import "AGProcess.h"
#import "PMMonitoringService.h"
#import "PlugInController.h"


@interface PMMainWindowController : NSWindowController
{
	PlugInController *m_controller;
	NSTimer *m_redrawTimer;
	NSMutableArray *m_layers;
	BOOL m_needsRedraw;
	IBOutlet NSScrollView *m_scrollView;
	NSView *m_documentView;
	CATextLayer *m_noSessionTextLayer;
}
- (id)initWithWindowNibName:(NSString *)windowNibName plugInController:(PlugInController *)controller;
- (void)removeLayerWithConnection:(ZZConnection *)conn;
@end