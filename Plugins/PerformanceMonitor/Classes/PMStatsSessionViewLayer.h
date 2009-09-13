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
#import "PMStatsViewLayer.h"


@interface PMStatsSessionViewLayer : CALayer
{
	id m_representedObject;
	PMStatsViewLayer *m_statsLayer;
	CATextLayer *m_titleLabel;
	CALayer *m_fpsSwatch;
	CATextLayer *m_fpsLabel;
	CALayer *m_memorySwatch;
	CATextLayer *m_memoryLabel;
	BOOL m_dirty;
}
@property (nonatomic, assign) id representedObject;
@property (nonatomic, assign) BOOL dirty;
- (void)setTitle:(NSString *)aTitle;
- (void)setFPS:(NSNumber *)fps;
- (void)setMemory:(NSNumber *)memory;
- (void)setColors:(NSArray *)colors;
- (void)setStatsData:(NSArray *)data;
- (NSArray *)statsData;
- (void)redrawIfNeeded;
@end