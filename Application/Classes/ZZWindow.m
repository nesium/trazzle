//
//  ZZWindow.m
//  Trazzle
//
//  Created by Marc Bauer on 16.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZWindow.h"


@implementation ZZWindow

- (BOOL)_showOpaqueGrowBox
{
	return NO;
}

- (void)_setShowOpaqueGrowBoxForOwner:(id)owner
{
	NSLog(@"owner: %@", owner);
}

@end