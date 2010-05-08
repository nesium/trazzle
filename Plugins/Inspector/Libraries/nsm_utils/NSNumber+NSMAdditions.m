//
//  NSNumber+PSAdditions.m
//  ProSieben
//
//  Created by Marc Bauer on 22.02.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "NSNumber+NSMAdditions.h"


@implementation NSNumber (NSMAdditions)

static BOOL g_initialized = NO;

+ (NSNumber *)nsm_numberWithRandomFloat{
	return [NSNumber numberWithFloat:[NSNumber nsm_randomFloat]];
}

+ (CGFloat)nsm_randomFloat{
	if (!g_initialized){
		srandom(time(NULL));
		g_initialized = YES;
	}
	return (float)random() / RAND_MAX;
}
@end