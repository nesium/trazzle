//
//  PMStatsSessionViewLayer.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface PMStatsSessionViewLayer : CALayer
{
	CATextLayer *m_textLayer;
}
- (void)setTitle:(NSString *)aTitle;
@end