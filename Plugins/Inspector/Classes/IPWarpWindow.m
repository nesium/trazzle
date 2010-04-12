//
//  IPWarpWindow.m
//  Inspector
//
//  Created by Marc Bauer on 12.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "IPWarpWindow.h"

#define kMeshWidth 20
#define kMeshHeight 20
#define kWarpDuration 0.45f
#define kFrameRate 1.0f/60.0f

@interface IPWarpWindow (Private)
- (void)_warpFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint hide:(BOOL)hide;
- (void)_animationComplete;
@end

@implementation IPWarpWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle 
	backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation{
	if (self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType 
		defer:deferCreation]){
		m_animationTimer = nil;
		m_durations = 0x0;
	}
	return self;
}

- (void)warpFromPoint:(NSPoint)aPoint{
	aPoint.y = NSHeight([[self screen] visibleFrame]) - aPoint.y;
	CGSConnectionID cid = _CGSDefaultConnection();
	CGRect frame;
	CGSGetWindowBounds(cid, [self windowNumber], &frame);
	[self _warpFromPoint:NSPointToCGPoint(aPoint) toPoint:frame.origin hide:NO];
}

- (void)warpToPoint:(NSPoint)aPoint{
	aPoint.y = NSHeight([[self screen] visibleFrame]) - aPoint.y;
	CGRect frame;
	CGSConnectionID cid = _CGSDefaultConnection();
	CGSGetWindowBounds(cid, [self windowNumber], &frame);
	[self _warpFromPoint:frame.origin toPoint:NSPointToCGPoint(aPoint) hide:YES];
}


#pragma mark -
#pragma mark Private methods

- (void)_warpFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint hide:(BOOL)hide{
	if (m_animationTimer){
		free(m_durations);
		[m_animationTimer invalidate];
	}

	CGFloat maxDistance = 0.0f;
	CGFloat distances[kMeshHeight][kMeshWidth];
	CGRect frame;
	CGSConnectionID cid = _CGSDefaultConnection();
	CGSGetWindowBounds(cid, [self windowNumber], &frame);
	for (int h = 0; h < kMeshHeight; h++){
		for (int w = 0; w < kMeshHeight; w++){
			CGPoint localPoint = (CGPoint){w * (frame.size.width / (kMeshWidth - 1)), 
				h * (frame.size.height / (kMeshHeight - 1))};
			CGPoint currentPos, targetPos;
			if (YES || hide){
				currentPos = (CGPoint){localPoint.x + fromPoint.x, localPoint.y + fromPoint.y};
				targetPos = toPoint;
			}else{
				currentPos = fromPoint;
				targetPos = (CGPoint){localPoint.x + toPoint.x, localPoint.y + toPoint.y};
			}

			CGFloat distance = sqrtf(/*powf(targetPos.x - currentPos.x, 2.0f) + */
				powf(targetPos.y - currentPos.y, 2.0f));
			maxDistance = MAX(maxDistance, distance);
			distances[h][w] = distance;
		}
	}
	m_durations = malloc(sizeof(CGFloat) * kMeshWidth * kMeshHeight);
	int i = 0;
	for (int h = 0; h < kMeshHeight; h++){
		for (int w = 0; w < kMeshHeight; w++){
			CGFloat distance = distances[h][w];
			CGFloat duration = kWarpDuration / 100 * (distance / (maxDistance / 100));
			*(m_durations + i++) = duration;
		}
	}
	
	if (!hide){
		CGSSetWindowAlpha(cid, [self windowNumber], 0.0f);
	}
	
	m_isHideAnimation = hide;
	m_animationStartTime = [[NSDate date] timeIntervalSinceReferenceDate];
	m_animationTargetPoint = hide ? toPoint : fromPoint;
	m_animationTimer = [NSTimer scheduledTimerWithTimeInterval:kFrameRate target:self 
		selector:@selector(timer_tick:) userInfo:nil repeats:YES];
	[self setHasShadow:NO];
	[self setLevel:kCGFloatingWindowLevel];
}

- (void)_animationComplete{
	if (!m_isHideAnimation){
		[self setHasShadow:YES];
		[self makeKeyWindow];
	}else{
		[self orderOut:self];
	}
	CGSConnectionID cid = _CGSDefaultConnection();
	CGSSetWindowWarp(cid, [self windowNumber], 0, 0, NULL);
}



#pragma mark -
#pragma mark NSTimer callback methods

- (void)timer_tick:(id)sender{
	NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
	NSTimeInterval timeIntervalDiff = currentTimeInterval - m_animationStartTime;
	
	CGPointWarp meshes[kMeshHeight][kMeshWidth];
	CGSConnectionID cid = _CGSDefaultConnection();
	CGRect frame;
	CGSGetWindowBounds(cid, [self windowNumber], &frame);
	
	int i = 0;
	for (int h = 0; h < kMeshHeight; h++){
		for (int w = 0; w < kMeshWidth; w++){
			CGPointWarp point;
			point.local.x = w * (frame.size.width / (kMeshWidth - 1));
			point.local.y = h * (frame.size.height / (kMeshHeight - 1));
			
			CGPoint currentPos, targetPos;
			if (m_isHideAnimation){
				currentPos = (CGPoint){point.local.x + frame.origin.x, 
					point.local.y + frame.origin.y};
				targetPos = m_animationTargetPoint;
			}else{
				currentPos = m_animationTargetPoint;
				targetPos = (CGPoint){point.local.x + frame.origin.x, 
					point.local.y + frame.origin.y};
			}
			
			CGSize posDiff = (CGSize){targetPos.x - currentPos.x, targetPos.y - currentPos.y};
			CGFloat duration = *(m_durations + i++);
			if (timeIntervalDiff >= duration){
				point.global.x = targetPos.x;
				point.global.y = targetPos.y;
			}else{
				point.global.x = NSMQuadEaseOut(timeIntervalDiff, currentPos.x, posDiff.width, 
					duration);
				point.global.y = NSMQuadEaseOut(timeIntervalDiff, currentPos.y, posDiff.height, 
					duration);
			}
			meshes[h][w] = point;
		}
	}
	CGFloat alpha;
	if (m_isHideAnimation){
		alpha = NSMQuadEaseOut(timeIntervalDiff, 1.0f, -1.0f, kWarpDuration);
	}else{
		alpha = NSMQuadEaseOut(timeIntervalDiff, 0.0f, 1.0f, kWarpDuration);
	}
	CGSSetWindowAlpha(cid, [self windowNumber], alpha);
	CGSSetWindowWarp(cid, [self windowNumber], kMeshWidth, kMeshHeight, meshes);
	
	if (timeIntervalDiff >= kWarpDuration){
		[m_animationTimer invalidate];
		m_animationTimer = nil;
		free(m_durations);
		[self _animationComplete];
	}
}
@end