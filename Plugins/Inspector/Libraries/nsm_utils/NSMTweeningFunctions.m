//
//  NSMTweeningFunctions.m
//  WindowWarpTest
//
//  Created by Marc Bauer on 12.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "NSMTweeningFunctions.h"


CGFloat NSMQuadEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	return c * (t /= d) * t + b;
}

CGFloat NSMQuadEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	return -c * (t /= d) * (t - 2.0f) + b;
}

CGFloat NSMQuadEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	if ((t /=d / 2.0f) < 1.0f) return c / 2.0f * t * t + b;
	return -c / 2.0f * ((--t) * (t - 2.0f) - 1.0f) + b;
}


CGFloat NSMBounceEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	if ((t /= d) < (1.0f / 2.75f)){
		return c * (7.5625f * t * t) + b;
	}else if (t < (2.0f / 2.75f)){
		return c * (7.5625f * (t -= (1.5f / 2.75f)) * t + 0.75f) + b;
	}else if (t < (2.5f / 2.75f)){
		return c * (7.5625f * (t -= (2.25f / 2.75f)) * t + 0.9375f) + b;
	}else{
		return c * (7.5625f * (t -= (2.625f / 2.75f)) * t + 0.984375) + b;
	}
}

CGFloat NSMBounceEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	return c - NSMBounceEaseOut(d - t, 0.0f, c, d) + b;
}

CGFloat NSMBounceEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d){
	if (t < d / 2.0f) return NSMBounceEaseIn(t * 2.0f, 0.0f, c, d) * 0.5f + b;
	else return NSMBounceEaseOut(t * 2.0f - d, 0.0f, c, d) * 0.5f + c * 0.5f + b;
}


CGFloat NSMBackEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s){
	return c * (t /= d) * t * ((s + 1.0f) * t - s) + b;
}

CGFloat NSMBackEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s){
	return c * ((t = t / d - 1.0f) * t * ((s + 1.0f) * t + s) + 1.0f) + b;
}

CGFloat NSMBackEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s){
	if ((t /= d / 2.0f) < 1.0f) return c / 2.0f * (t * t * (((s *= (1.525f)) + 1.0f) * t - s)) + b;
	return c / 2.0f * ((t -= 2.0f) * t * (((s *= (1.525f)) + 1.0f) * t + s) + 2.0f) + b;
}