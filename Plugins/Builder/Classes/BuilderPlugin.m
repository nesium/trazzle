//
//  BuilderPlugin.m
//  Builder
//
//  Created by Marc Bauer on 16.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "BuilderPlugin.h"


@implementation BuilderPlugin

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		controller = aController;
		[controller addTabWithIdentifier:@"BuilderMain" view:[[[NSView alloc] init] autorelease] 
			delegate:self];
		m_compilerSettingsController = [[BLDCompilerSettingsWindowController alloc] init];
	}
	return self;
}

- (NSString *)titleForTabWithIdentifier:(NSString *)identifier
{
	return @"Compiler Shell";
}

@end