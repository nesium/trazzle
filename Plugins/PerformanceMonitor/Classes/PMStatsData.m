//
//  PMStatsData.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMStatsData.h"


@implementation PMStatsData

@synthesize values=m_values, 
			peak=m_peak;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_values = [[NSMutableArray alloc] init];
		m_peak = [NSNumber numberWithInt:0];
	}
	return self;
}

- (void)dealloc
{
	[m_values release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)addValue:(NSNumber *)value withDate:(NSDate *)date
{
	[m_values addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		date, @"Date", value, @"Value", nil]];
	if ([value doubleValue] > [m_peak doubleValue])
		m_peak = value;
}
@end