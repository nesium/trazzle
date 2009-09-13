//
//  PMStatsSessionViewLayer.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMStatsSessionViewLayer.h"


@implementation PMStatsSessionViewLayer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_textLayer = [CATextLayer layer];
		[self addSublayer:m_textLayer];
		m_textLayer.truncationMode = kCATruncationEnd;
		self.layoutManager = [CAConstraintLayoutManager layoutManager];
		m_textLayer.autoresizingMask = kCALayerWidthSizable;
		m_textLayer.fontSize = 11.0;
		m_textLayer.shadowOpacity = 0.5;
		m_textLayer.shadowOffset = (CGSize){1.0, -1.0};
		m_textLayer.shadowRadius = 1.0;
		m_textLayer.font = [NSFont boldSystemFontOfSize:11.0];
		[m_textLayer addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:10.0]];
		[m_textLayer addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" 
				attribute:kCAConstraintMaxY scale:1.0 offset:-5.0]];
	}
	return self;
}

- (void)setTitle:(NSString *)aTitle
{
	m_textLayer.string = aTitle;
}
@end