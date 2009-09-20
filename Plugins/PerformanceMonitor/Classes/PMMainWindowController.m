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
- (void)_updateWindowFrame;
- (void)_updateLayerPositions;
- (NSRect)_windowFrame;
- (void)_resizeLayers;
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
	NSSize contentSize = [m_scrollView contentSize];
	m_documentView = [[NSView alloc] initWithFrame:(NSRect){0, 0, contentSize.width, 
		contentSize.height}];
	[m_documentView setWantsLayer:YES];
	[m_scrollView setDocumentView:m_documentView];
	[m_documentView release];
	
	CAAnimation *winAlphaAnim = [CABasicAnimation animation];
    [winAlphaAnim setDelegate:self];
    [self.window setAnimations:[NSDictionary dictionaryWithObject:winAlphaAnim forKey:@"alphaValue"]];
	
	CAAnimation *winFrameAnim = [CABasicAnimation animation];
	[winFrameAnim setDelegate:self];
	[winFrameAnim setValue:@"window" forKey:@"name"];
	[self.window setAnimations:[NSDictionary dictionaryWithObject:winFrameAnim forKey:@"frame"]];
	
	CAAnimation *documentViewFrameAnim = [CABasicAnimation animation];
	[documentViewFrameAnim setDelegate:self];
	[documentViewFrameAnim setValue:@"documentView" forKey:@"name"];
	[m_documentView setAnimations:[NSDictionary dictionaryWithObject:documentViewFrameAnim 
		forKey:@"frameSize"]];
	
	m_noSessionTextLayer = [CATextLayer layer];
	[m_documentView.layer addSublayer:m_noSessionTextLayer];
	m_noSessionTextLayer.string = @"No active session";
	m_noSessionTextLayer.fontSize = 11.0;
	m_noSessionTextLayer.font = [NSFont systemFontOfSize:11.0];
	m_noSessionTextLayer.alignmentMode = kCAAlignmentCenter;
	m_noSessionTextLayer.frame = (CGRect){0.0f, roundf((contentSize.height - 11.0f) / 2) + 5.0f, 
		contentSize.width, 11.0f};
	CGColorRef color = CGColorCreateGenericGray(0.6, 1.0);
	m_noSessionTextLayer.foregroundColor = color;
	CGColorRelease(color);
}

- (IBAction)showWindow:(id)sender
{
	if (![self.window isVisible])
    {
        self.window.alphaValue = 0.0;
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.15];
        [self.window.animator setAlphaValue:1.0];
		[NSAnimationContext endGrouping];
    }
    [super showWindow:sender];
}



#pragma mark -
#pragma mark Public methods

- (void)removeLayerWithConnection:(ZZConnection *)conn
{
	PMStatsSessionViewLayer *layer = [self _layerForConnection:conn];
	layer.zPosition = -1;
	[layer removeFromSuperlayer];
	[m_layers removeObject:layer];
	[self _updateWindowFrame];
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
	PMStatsSessionViewLayer *layer = [PMStatsSessionViewLayer layer];
	layer.frame = (CGRect){0, 0, [m_scrollView contentSize].width, 100};
	layer.anchorPoint = (CGPoint){0.0f, 0.0f};
	NSArray *colors = [NSArray arrayWithObjects:[NSColor cyanColor], [NSColor magentaColor], nil];
	[layer setColors:colors];
	NSArray *stats = [NSArray arrayWithObjects:[[PMStatsData alloc] init], 
		[[PMStatsData alloc] init], nil];
	[layer setStatsData:stats];
	layer.representedObject = conn;
	[m_layers addObject:layer];
	
	[[m_documentView layer] addSublayer:layer];
	[self _updateWindowFrame];
	
	return layer;
}

- (void)_updateWindowFrame
{
	m_noSessionTextLayer.opacity = [m_layers count] == 0 ? 1.0 : 0.0;
	
	NSRect windowFrame = [[self window] frame];
	NSRect newWindowFrame = [self _windowFrame];
	NSRect contentViewFrame = [[[self window] contentView] frame];
	BOOL isShrinking = newWindowFrame.size.height < windowFrame.size.height;
	NSRect documentViewRect = (NSRect){0, 0, contentViewFrame.size.width, 
		MAX([m_layers count], 1) * 100.0f};

	[[m_documentView animator] setFrame:documentViewRect];
	[[[self window] animator] setFrame:newWindowFrame display:YES];
	[self _updateLayerPositions];
	if (isShrinking)
		[m_scrollView setHasVerticalScroller:NO];
}

- (void)_updateLayerPositions
{
	float y = MAX([m_layers count], 1) * 100.0f;
	float x = 0.0f;
	for (PMStatsSessionViewLayer *layer in m_layers)
	{
		y -= 100.0f;
		layer.position = (CGPoint){x, y};
		layer.drawsDivider = layer != [m_layers lastObject];
	}
}

- (NSRect)_windowFrame
{
	NSRect windowFrame = [[self window] frame];
	NSRect contentViewFrame = [[[self window] contentView] frame];
	CGFloat heightDiff = windowFrame.size.height - contentViewFrame.size.height;
	NSRect newContentViewFrame = contentViewFrame;
	newContentViewFrame.size.height = MAX(MIN([m_layers count], 3), 1) * 100.0f + 6.0f;
	NSRect newWindowFrame = windowFrame;
	newWindowFrame.size.height = newContentViewFrame.size.height + heightDiff;
	newWindowFrame.origin.y -= newWindowFrame.size.height - windowFrame.size.height;
	return newWindowFrame;
}

- (void)_resizeLayers
{
	NSSize contentSize = [m_scrollView contentSize];
	NSRect documentViewFrame = [m_documentView frame];
	documentViewFrame.size.width = contentSize.width;
	[m_documentView setFrame:documentViewFrame];
	for (CALayer *layer in m_layers)
	{
		CGRect layerFrame = layer.frame;
		layerFrame.size.width = contentSize.width;
		layer.frame = layerFrame;
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

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
	if ([[animation valueForKey:@"name"] isEqualToString:@"documentView"])
	{
		NSSize contentSize = [m_scrollView contentSize];
		BOOL wasShrinking = contentSize.height > [m_documentView frame].size.height;
		if (wasShrinking)
			[m_scrollView setHasVerticalScroller:YES];
	}
	else if ([[animation valueForKey:@"name"] isEqualToString:@"window"])
	{
		[self _resizeLayers];
	}
	else
	{
		if (self.window.alphaValue == 0.00)
			[self close];
	}
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



#pragma mark -
#pragma mark Window delegate methods

- (BOOL)windowShouldClose:(id)window
{
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.15];
	[self.window.animator setAlphaValue:0.0];
	[NSAnimationContext endGrouping];
    return NO;
}

@end