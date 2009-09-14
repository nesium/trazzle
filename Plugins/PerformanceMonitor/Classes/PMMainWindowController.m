//
//  PMMainWindowController.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMMainWindowController.h"

@interface PMMainWindowController (Private)
- (PMStatsSessionViewLayer *)_layerForConnection:(ZZConnection *)conn;
- (PMStatsSessionViewLayer *)_addLayerWithConnection:(ZZConnection *)conn;
- (void)_updateLayerPositions;
@end


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
	m_documentView = [[NSView alloc] initWithFrame:NSZeroRect];
	[m_documentView setWantsLayer:YES];
	[m_scrollView setDocumentView:m_documentView];
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
#pragma mark Public methods

- (void)removeLayerWithConnection:(ZZConnection *)conn
{
	PMStatsSessionViewLayer *layer = [self _layerForConnection:conn];
	[layer removeFromSuperlayer];
	[m_layers removeObject:layer];
	[self _updateLayerPositions];
	if ([m_layers count] == 0)
		[[self window] close];
}



#pragma mark -
#pragma mark Private methods

- (PMStatsSessionViewLayer *)_layerForConnection:(ZZConnection *)conn
{
	for (PMStatsSessionViewLayer *layer in m_layers)
		if (layer.representedObject == conn)
			return layer;
	return nil;
}

- (PMStatsSessionViewLayer *)_addLayerWithConnection:(ZZConnection *)conn
{
	NSRect windowFrame = [[self window] frame];
	NSRect contentViewFrame = [[[self window] contentView] frame];
	CGFloat heightDiff = windowFrame.size.height - contentViewFrame.size.height;
	NSRect newWindowFrame = windowFrame;
	newWindowFrame.size.height = MIN(([m_layers count] + 1), 3) * 100 + heightDiff;

	PMStatsSessionViewLayer *layer = [PMStatsSessionViewLayer layer];
	layer.frame = (CGRect){0, 0, contentViewFrame.size.width, 100};
	[layer setNeedsDisplay];
	NSArray *colors = [NSArray arrayWithObjects:[NSColor cyanColor], [NSColor magentaColor], nil];
	[layer setColors:colors];
	NSArray *stats = [NSArray arrayWithObjects:[[PMStatsData alloc] init], 
		[[PMStatsData alloc] init], nil];
	[layer setStatsData:stats];
	layer.representedObject = conn;
	[m_layers addObject:layer];
	
	[[m_documentView layer] addSublayer:layer];
	
	[self _updateLayerPositions];
	
	return layer;
}

- (void)_updateLayerPositions
{
	NSRect windowFrame = [[self window] frame];
	NSRect contentViewFrame = [[[self window] contentView] frame];
	CGFloat heightDiff = windowFrame.size.height - contentViewFrame.size.height;
	NSRect newWindowFrame = windowFrame;
	newWindowFrame.size.height = MAX(MIN([m_layers count], 3), 1) * 100.0f + heightDiff + 6.0f;
	[m_documentView setFrame:(NSRect){0, 0, contentViewFrame.size.width, [m_layers count] * 100.0f}];
	[[[self window] animator] setFrame:newWindowFrame display:YES];

	float y = [m_layers count] * 100.0f - 50.0f;
	float x = [[[self window] contentView] bounds].size.width / 2;
	for (CALayer *layer in m_layers)
	{
		layer.position = (CGPoint){x, y};
		y -= 100.0f;
	}
}



#pragma mark -
#pragma mark Events

- (void)redrawTimer_tick:(NSTimer *)timer
{
	if (!m_needsRedraw) return;
	for (PMStatsSessionViewLayer *layer in m_layers)
		[layer redrawIfNeeded];
	m_needsRedraw = NO;
}



#pragma mark -
#pragma mark PMMonitoringServiceDelegate methods

- (void)service:(PMMonitoringService *)service startMonitoring:(NSNumber *)maxFPS 
	forRemote:(AMFRemoteGateway *)remote
{
	if (![[self window] isVisible])
		[self showWindow:self];
	ZZConnection *conn = [m_controller connectionForRemote:remote];
	PMStatsSessionViewLayer *layer = [self _layerForConnection:conn];
	if (layer == nil)
		layer = [self _addLayerWithConnection:conn];
	[layer setTitle:conn.applicationName];
}

- (void)service:(PMMonitoringService *)service trackFPS:(NSNumber *)fps memoryUse:(NSNumber *)memory 
	timestamp:(NSNumber *)timestamp forRemote:(AMFRemoteGateway *)remote
{
	PMStatsSessionViewLayer *layer = [self _layerForConnection:
		[m_controller connectionForRemote:remote]];
	PMStatsData *data = [[layer statsData] objectAtIndex:0];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue] / 1000];
	[data addValue:fps withDate:date];
	data = [[layer statsData] objectAtIndex:1];
	[data addValue:memory withDate:date];
	[layer setFPS:fps];
	[layer setMemory:memory];
	layer.dirty = YES;
	m_needsRedraw = YES;
}

- (void)serviceStopMonitoring:(PMMonitoringService *)service forRemote:(AMFRemoteGateway *)remote
{
	[self removeLayerWithConnection:[m_controller connectionForRemote:remote]];
}

@end