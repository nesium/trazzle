//
//  PMMainWindowController.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMMainWindowController.h"

static int initialized = 0;

int irnd(int max_value)
{
	if (initialized == 0)
	{
		srandom(time(NULL));
		initialized = 1;
	}
	return (int)lround(((double)random() / RAND_MAX) * max_value);
}


@implementation PMMainWindowController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		m_redrawTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
			selector:@selector(redrawTimer_tick:) userInfo:nil repeats:YES];
		m_layers = [[NSMutableArray alloc] init];
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
	
	NSArray *colors = [NSArray arrayWithObject:[NSColor cyanColor]];
	[layer setStrokeColors:colors];
	NSArray *stats = [NSArray arrayWithObject:[[PMStatsData alloc] init]];
	layer.statsData = stats;
	
	[m_layers addObject:layer];
}



#pragma mark -
#pragma mark Events

- (void)redrawTimer_tick:(NSTimer *)timer
{
	for (PMStatsViewLayer *layer in m_layers)
	{
		PMStatsData *data = [layer.statsData objectAtIndex:0];
		for (uint16_t i = 0; i < 20; i++)
			[data addValue:[NSNumber numberWithInt:irnd(10)] withDate:[NSDate date]];
		[layer setNeedsDisplay];
	}
}

@end