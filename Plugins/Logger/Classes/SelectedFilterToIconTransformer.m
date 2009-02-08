//
//  SelectedFilterToIconTransformer.m
//  Trazzle
//
//  Created by Marc Bauer on 26.06.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SelectedFilterToIconTransformer.h"


@implementation SelectedFilterToIconTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}
 
+ (BOOL)allowsReverseTransformation
{
	return NO;
}
 
- (id)transformedValue:(LPFilter *)filter
{
	return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] 
		pathForResource:@"led_off" ofType:@"png"]] autorelease];
//	BOOL filterSelected = filter == [[FilterModel defaultModel] activeFilter];
//	if (!filterSelected)
//	{
//		return nil;
//	}
//	return [[[FilterModel defaultModel] filteringEnabled] boolValue]
//		? [NSImage imageNamed:@"led_on.png"]
//		: [NSImage imageNamed:@"led_off.png"];
}

@end