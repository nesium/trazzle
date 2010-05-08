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
#import "PMMonitoringService.h"
#import "ZZPlugInController.h"


@interface PMMainWindowController : NSWindowController{
	ZZPlugInController *m_controller;
	NSTimer *m_redrawTimer;
	NSMutableArray *m_layers;
	BOOL m_needsRedraw;
	IBOutlet NSScrollView *m_scrollView;
	NSView *m_documentView;
	CATextLayer *m_noSessionTextLayer;
}
- (id)initWithWindowNibName:(NSString *)windowNibName plugInController:(ZZPlugInController *)controller;
- (void)removeLayerWithConnection:(ZZConnection *)conn;
@end