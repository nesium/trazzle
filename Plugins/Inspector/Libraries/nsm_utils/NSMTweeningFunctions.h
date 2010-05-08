//
//  NSMTweeningFunctions.h
//  WindowWarpTest
//
//  Created by Marc Bauer on 12.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>

// t: current time, b: beginning value, c: change in value, d: duration

CGFloat NSMQuadEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);
CGFloat NSMQuadEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);
CGFloat NSMQuadEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);

CGFloat NSMBounceEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);
CGFloat NSMBounceEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);
CGFloat NSMBounceEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d);

// try 1.70158f for parameter s
CGFloat NSMBackEaseIn(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s);
CGFloat NSMBackEaseOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s);
CGFloat NSMBackEaseInOut(NSTimeInterval t, CGFloat b, CGFloat c, NSTimeInterval d, CGFloat s);