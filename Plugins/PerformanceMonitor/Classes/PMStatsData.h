//
//  PMStatsData.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PMStatsData : NSObject
{
	NSMutableArray *m_values;
	NSNumber *m_peak;
}
@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, readonly) NSNumber *peak;
- (void)addValue:(NSNumber *)value withDate:(NSDate *)date;
@end