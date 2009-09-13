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
		m_titleLabel = [CATextLayer layer];
		[self addSublayer:m_titleLabel];
		m_titleLabel.truncationMode = kCATruncationEnd;
		self.layoutManager = [CAConstraintLayoutManager layoutManager];
		m_titleLabel.autoresizingMask = kCALayerWidthSizable;
		m_titleLabel.fontSize = 10.0;
		m_titleLabel.shadowOpacity = 0.5;
		m_titleLabel.shadowOffset = (CGSize){1.0, -1.0};
		m_titleLabel.shadowRadius = 1.0;
		m_titleLabel.font = [NSFont boldSystemFontOfSize:10.0];
		[m_titleLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:10.0]];
		[m_titleLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" 
				attribute:kCAConstraintMaxY scale:1.0 offset:-5.0]];
		
		m_fpsSwatch = [CALayer layer];
		[self addSublayer:m_fpsSwatch];
		m_fpsSwatch.frame = (CGRect){0, 0, 7.0, 7.0};
		[m_fpsSwatch addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" 
				attribute:kCAConstraintMinY scale:1.0 offset:17.0]];
		[m_fpsSwatch addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:10.0]];
								
		m_fpsLabel = [CATextLayer layer];
		[self addSublayer:m_fpsLabel];
		m_fpsLabel.fontSize = 9.0;
		m_fpsLabel.font = [NSFont systemFontOfSize:9.0];
		[m_fpsLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" 
				attribute:kCAConstraintMinY scale:1.0 offset:15.0]];
		[m_fpsLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:22.0]];
		
		m_memorySwatch = [CALayer layer];
		[self addSublayer:m_memorySwatch];
		m_memorySwatch.frame = (CGRect){0, 0, 7.0, 7.0};
		[m_memorySwatch addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" 
				attribute:kCAConstraintMinY scale:1.0 offset:17.0]];
		[m_memorySwatch addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:70.0]];
		
		m_memoryLabel = [CATextLayer layer];
		[self addSublayer:m_memoryLabel];
		m_memoryLabel.fontSize = 9.0;
		m_memoryLabel.font = [NSFont systemFontOfSize:9.0];
		[m_memoryLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" 
				attribute:kCAConstraintMinY scale:1.0 offset:15.0]];
		[m_memoryLabel addConstraint:
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" 
				attribute:kCAConstraintMinX scale:1.0 offset:82]];		
	}
	return self;
}

- (void)setTitle:(NSString *)aTitle
{
	m_titleLabel.string = aTitle;
}

- (void)setColors:(NSArray *)colors
{
	CGColorRef color = [(NSColor *)[colors objectAtIndex:0] CGColorCopy];
	m_fpsSwatch.backgroundColor = color;
	CGColorRelease(color);
	color = [(NSColor *)[colors objectAtIndex:1] CGColorCopy];
	m_memorySwatch.backgroundColor = color;
	CGColorRelease(color);
}

- (void)setFPS:(NSNumber *)fps
{
	m_fpsLabel.string = [NSString stringWithFormat:@"%d fps", [fps intValue]];
}

- (void)setMemory:(NSNumber *)memory
{
	m_memoryLabel.string = [memory fileSizeString];
}
@end