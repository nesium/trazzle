//
//  PMStatsSessionViewLayer.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "NSNumber+FileSize.h"
#import "NSColor+Additions.h"


@interface PMStatsSessionViewLayer : CALayer
{
	CATextLayer *m_titleLabel;
	CALayer *m_fpsSwatch;
	CATextLayer *m_fpsLabel;
	CALayer *m_memorySwatch;
	CATextLayer *m_memoryLabel;
}
- (void)setTitle:(NSString *)aTitle;
- (void)setFPS:(NSNumber *)fps;
- (void)setMemory:(NSNumber *)memory;
- (void)setColors:(NSArray *)colors;
@end