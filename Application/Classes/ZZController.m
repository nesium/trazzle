//
//  DocumentController.m
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "ZZController.h"

@interface ZZController (Private)
- (void)loadPlugins;
@end


@implementation ZZController

#pragma mark -
#pragma mark Initialization & deallocation

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}

- (void)awakeFromNib
{
	m_windowController = [[ZZWindowController alloc] initWithWindowNibName:@"MainWindow"];
	m_plugInControllers = [[NSMutableArray alloc] init];
	[self loadPlugins];
}



#pragma mark -
#pragma mark Private methods

- (void)loadPlugins
{
	m_loadedPlugins = [[NSMutableArray alloc] init];
	NSString *pluginsPath = [[NSBundle mainBundle] builtInPlugInsPath];
	NSArray *plugins = [[NSFileManager defaultManager] directoryContentsAtPath:pluginsPath];

	for (NSString *path in plugins)
	{
		if (![[path pathExtension] isEqualToString:@"trazzlePlugin"])
		{
			continue;
		}
		
		NSBundle *pluginBundle = [NSBundle bundleWithPath:[pluginsPath 
			stringByAppendingPathComponent:path]];
		NSError *error = nil;
		if (![pluginBundle loadAndReturnError:&error])
		{
			NSLog(@"Error loading plugin: %@", error);
			continue;
		}
		
		Class prinClass = [pluginBundle principalClass];
		if (prinClass && class_conformsToProtocol(prinClass, @protocol(TrazzlePlugIn)))
		{
			PlugInController *plugInController = [[PlugInController alloc] 
				initWithPlugInBundle:pluginBundle windowController:m_windowController];
			[m_plugInControllers addObject:plugInController];
			
			NSObject <TrazzlePlugIn> *plugin = [[prinClass alloc] 
				initWithPlugInController:plugInController];
			[m_loadedPlugins addObject:plugin];
			[plugin release];
			[plugInController release];
		}
	}
}

@end