//
//  StatsViewLayer.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMStatsViewLayer.h"


@implementation PMStatsViewLayer

@synthesize statsData=m_statsData;

- (id)init
{
	if (self = [super init])
	{
		m_numColors = 0;
		m_strokeColors = nil;
		m_entriesPerPage = 100;
	}
	return self;
}

- (void)dealloc
{
	for (uint16_t i = 0; i < m_numColors; i++)
		CGColorRelease(m_strokeColors[i]);
	free(m_strokeColors);
	[super dealloc];
}

- (id<CAAction>)actionForKey:(NSString *)event
{
	if ([event isEqualToString:@"contents"]) return nil;
	return [super actionForKey:event];
}

- (void)setStrokeColors:(NSArray *)colors
{
	for (uint16_t i = 0; i < m_numColors; i++)
		CGColorRelease(m_strokeColors[i]);

	free(m_strokeColors);
	m_strokeColors = malloc(sizeof(CGColorRef) * [colors count]);
	uint16_t i = 0;
	for (NSColor *color in colors)
	{
		CGColorRef cgColor = [color CGColorCopy];
		m_strokeColors[i++] = cgColor;
	}
}

- (void)drawInContext:(CGContextRef)ctx
{
	CGRect fillRect = self.bounds;
	CGContextSaveGState(ctx);
	
//	CGContextSaveGState(ctx);
//	CGContextSetGrayFillColor(ctx, 0.0, 0.3);
//	CGContextFillRect(ctx, fillRect);
//	CGContextRestoreGState(ctx);

//	CGContextSaveGState(ctx);
//	CGContextSetGrayStrokeColor(ctx, 0.0, 0.15);
//	CGContextMoveToPoint(ctx, fillRect.origin.x, CGRectGetMaxY(fillRect));
//	CGContextAddLineToPoint(ctx, CGRectGetMaxX(fillRect), CGRectGetMaxY(fillRect));
//	CGContextStrokePath(ctx);
//	CGContextRestoreGState(ctx);
//	
//	CGContextSaveGState(ctx);
//	CGContextSetGrayStrokeColor(ctx, 1.0, 0.25);
//	CGContextMoveToPoint(ctx, fillRect.origin.x, CGRectGetMinY(fillRect));
//	CGContextAddLineToPoint(ctx, CGRectGetMaxX(fillRect), CGRectGetMinY(fillRect));
//	CGContextStrokePath(ctx);
//	CGContextRestoreGState(ctx);

	fillRect = CGRectInset(fillRect, 0.0, 1.0);
	fillRect.origin.y += 1.0;

	CGContextSetLineWidth(ctx, 1.0f);
	uint32_t i = 0;
	for (PMStatsData *data in m_statsData)
	{
		float xRatio = (fillRect.size.width / (float)m_entriesPerPage);
		float yRatio = (fillRect.size.height / [data.peak floatValue]);
		CGColorRef color = m_strokeColors[i];
		CGContextSetStrokeColorWithColor(ctx, color);
		uint32_t j = data.values.count > m_entriesPerPage ? data.values.count - m_entriesPerPage : 0;
		uint32_t k = 0;
		for (; j < data.values.count; j++)
		{
			NSDictionary *dict = [data.values objectAtIndex:j];
			CGPoint p = (CGPoint){k * xRatio + fillRect.origin.x, 
				[[dict objectForKey:@"Value"] floatValue] * yRatio + fillRect.origin.y};
			if (k == 0)
				CGContextMoveToPoint(ctx, p.x, p.y);
			else
				CGContextAddLineToPoint(ctx, p.x, p.y);
			k++;
		}
		CGContextStrokePath(ctx);
		i++;
	}
	
	CGContextRestoreGState(ctx);
}
@end