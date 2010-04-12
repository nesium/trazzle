//
//  IPWarpWindow.h
//  Inspector
//
//  Created by Marc Bauer on 12.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CGSPrivate.h"
#import "NSNumber+NSMAdditions.h"
#import "NSMTweeningFunctions.h"


@interface IPWarpWindow : NSPanel{
	NSTimer *m_animationTimer;
	NSTimeInterval m_animationStartTime;
	CGPoint m_animationTargetPoint;
	CGFloat *m_durations;
	BOOL m_isHideAnimation;
}
- (void)warpFromPoint:(NSPoint)aPoint;
- (void)warpToPoint:(NSPoint)aPoint;
@end