//
//  PMMainWindowController.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMMainWindowController.h"

@implementation PMMainWindowController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithWindowNibName:(NSString *)windowNibName plugInController:(PlugInController *)controller
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		m_controller = controller;
		m_redrawTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
			selector:@selector(redrawTimer_tick:) userInfo:nil repeats:YES];
		m_layers = [[NSMutableArray alloc] init];
		m_needsRedraw = NO;
	}
	return self;
}

- (void)dealloc
{
	[m_redrawTimer invalidate];
	[super dealloc];
}



#pragma mark -
#pragma mark Overridden NSWindowController methods

- (NSString *)windowFrameAutosaveName
{
	return @"PMMainWindow";
}

- (void)windowDidLoad
{
	PMStatsSessionViewLayer *parentLayer = [PMStatsSessionViewLayer layer];

	PMStatsViewLayer *layer = [PMStatsViewLayer layer];
	NSRect winBounds = [[[self window] contentView] frame];
	parentLayer.frame = (CGRect){0, winBounds.size.height - 100, winBounds.size.width, 100};
	[[[[self window] contentView] layer] addSublayer:parentLayer];
	[parentLayer addSublayer:layer];
	layer.frame = (CGRect){10, 25, winBounds.size.width - 20, 50};
	
	NSArray *colors = [NSArray arrayWithObjects:[NSColor cyanColor], [NSColor magentaColor], nil];
	[layer setStrokeColors:colors];
	[parentLayer setColors:colors];
	NSArray *stats = [NSArray arrayWithObjects:[[PMStatsData alloc] init], 
		[[PMStatsData alloc] init], nil];
	layer.statsData = stats;
	
	[m_layers addObject:layer];
}

- (IBAction)showWindow:(id)sender
{
	NSWindow *win = [self window];
	[win setAlphaValue:0.0];
	[win makeKeyAndOrderFront:self];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.15];
	[[win animator] setAlphaValue:1.0];
	[NSAnimationContext endGrouping];
}



#pragma mark -
#pragma mark Events

- (void)redrawTimer_tick:(NSTimer *)timer
{
	if (!m_needsRedraw) return;
	for (PMStatsViewLayer *layer in m_layers)
		[layer setNeedsDisplay];
	m_needsRedraw = NO;
}



#pragma mark PMMonitoringServiceDelegate methods

- (void)service:(PMMonitoringService *)service startMonitoring:(NSNumber *)maxFPS 
	forRemote:(AMFRemoteGateway *)remote
{
	[self showWindow:self];
	PMStatsViewLayer *layer = [m_layers objectAtIndex:0];
	PMStatsSessionViewLayer *sessionLayer = (PMStatsSessionViewLayer *)layer.superlayer;
	[sessionLayer setTitle:[m_controller connectionForRemote:remote].applicationName];
}

- (void)service:(PMMonitoringService *)service trackFPS:(NSNumber *)fps memoryUse:(NSNumber *)memory 
	timestamp:(NSNumber *)timestamp forRemote:(AMFRemoteGateway *)remote
{
	PMStatsViewLayer *layer = [m_layers objectAtIndex:0];
	PMStatsData *data = [layer.statsData objectAtIndex:0];
	PMStatsSessionViewLayer *sessionLayer = (PMStatsSessionViewLayer *)layer.superlayer;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue] / 1000];
	[data addValue:fps withDate:date];
	data = [layer.statsData objectAtIndex:1];
	[data addValue:memory withDate:date];
	[sessionLayer setFPS:fps];
	[sessionLayer setMemory:memory];
	m_needsRedraw = YES;
}

- (void)serviceStopMonitoring:(PMMonitoringService *)service forRemote:(AMFRemoteGateway *)remote
{
}

@end