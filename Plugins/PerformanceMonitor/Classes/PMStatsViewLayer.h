//
//  StatsViewLayer.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PMStatsData.h"
#import "NSColor+Additions.h"


@interface PMStatsViewLayer : CALayer
{
	CGColorRef *m_strokeColors;
	NSArray *m_statsData;
	uint16_t m_numColors;
	uint16_t m_entriesPerPage;
}
@property (nonatomic, retain) NSArray *statsData;
- (void)setStrokeColors:(NSArray *)colors;
@end