//
//  FDBSourceModule.m
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FDBSourceModule.h"


@implementation FDBSourceModule

@synthesize index=m_module;

+ (FDBSourceModule *)moduleWithSWFIndex:(int32_t)swfIndex module:(uint32_t)module 
								 bitmap:(uint32_t)bitmap name:(NSString *)name text:(NSString *)text
{
	FDBSourceModule *sourceModule = [[FDBSourceModule alloc] 
									 initWithSWFIndex:swfIndex module:module 
									 bitmap:bitmap name:name text:text];
	return [sourceModule autorelease];
}

- (id)initWithSWFIndex:(int32_t)swfIndex module:(uint32_t)module bitmap:(uint32_t)bitmap
				  name:(NSString *)name text:(NSString *)text
{
	if (self = [super init])
	{
		m_swfIndex = swfIndex;
		m_module = module;
		m_bitmap = bitmap;
		m_text = [text retain];
		
		NSArray *parts = [name componentsSeparatedByString:@";"];
		if ([parts count] == 3)
		{
			// /Daten/Projekte/Fork/RitterSport/RSFPlatform/lib/reprise;reprise/ui;UIComponent.as
			m_path = [[[parts objectAtIndex:0] stringByAppendingPathComponent:
					  [parts objectAtIndex:2]] retain];
			m_package = [[parts objectAtIndex:1] retain];
		}
		
		NSLog(@"module: %d, path: %@, package: %@", m_module, m_path, m_package);
	}
	return self;
}

- (void)dealloc
{
	[m_path release];
	[m_package release];
	[super dealloc];
}

@end