//
//  LoggingViewScroller.m
//  Logger
//
//  Created by Marc Bauer on 14.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LoggingViewScroller.h"


@implementation LoggingViewScroller

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
	}
	return self;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)frame
{	
//	NSDisableScreenUpdates();
	
//	[[NSColor colorWithCalibratedRed:0.071 green:0.051 blue:0.051 alpha:1.0] 
//		drawSwatchInRect:[self bounds]];
//	[[NSColor redColor] drawSwatchInRect:[self rectForPart:NSScrollerKnob]];
	
	CGColorRef backgroundColor = CGColorCreateGenericRGB(0.067, 0.051, 0.051, 1.0);
	CGColorRef knobColor = CGColorCreateGenericRGB(0.220, 0.220, 0.220, 1.0);
	NSLog(@"superview %@", [self superview]);
	CGRect bounds = NSRectToCGRect([self bounds]);
	CGRect knobRect = NSRectToCGRect([self rectForPart:NSScrollerKnob]);
	knobRect.size.width -= 5;
	knobRect.origin.x += 3;

	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);
	CGContextSetFillColorWithColor(ctx, backgroundColor);
	CGContextFillRect(ctx, bounds);
	CGContextRestoreGState(ctx);
	
	CGFloat radius = MIN(knobRect.size.width, knobRect.size.height) / 2;
	CGMutablePathRef knobPath = CGPathCreateMutable();
	
	CGPathAddArc(knobPath, NULL, CGRectGetMidX(knobRect), CGRectGetMinY(knobRect) + radius, 
				 radius, M_PI, 0, NO);
	CGPathAddArc(knobPath, NULL, CGRectGetMidX(knobRect), CGRectGetMaxY(knobRect) - radius, 
				 radius, 0, M_PI, NO);
	CGPathCloseSubpath(knobPath);
	
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, knobPath);
	CGContextSetFillColorWithColor(ctx, knobColor);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);	

	CGPathRelease(knobPath);
	CGColorRelease(knobColor);
	CGColorRelease(backgroundColor);
	
//	[[self window] invalidateShadow];
//	NSEnableScreenUpdates();
}

- (BOOL)isVertical
{
	return (NSWidth([self frame]) < NSHeight([self frame]));
}

@end