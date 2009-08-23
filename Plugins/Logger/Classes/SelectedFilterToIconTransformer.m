//
//  SelectedFilterToIconTransformer.m
//  Trazzle
//
//  Created by Marc Bauer on 26.06.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SelectedFilterToIconTransformer.h"
#import "LPFilterController.h"


@implementation SelectedFilterToIconTransformer

- (id)initWithFilterController:(LPFilterController *)filterController
{
	if (self = [super init])
	{
		m_filterController = filterController;
	}
	return self;
}

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
	NSString *imageName;
	if (m_filterController.model.filteringIsEnabled && m_filterController.model.activeFilter == filter)
		imageName = @"led_on";
	else
		imageName = @"led_off";
	
	return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] 
		pathForResource:imageName ofType:@"png"]] autorelease];
}

@end