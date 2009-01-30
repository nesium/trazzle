//
//  DocumentController.m
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "Controller.h"

@interface Controller (Private)
- (void)loadPlugins;
@end


@implementation Controller

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
	m_windowController = [[WindowController alloc] initWithWindowNibName:@"MainWindow"];
	[m_windowController showWindow:self];
	m_pluginController = [[PlugInController alloc] init];
	[m_pluginController setValue:m_windowController forKey:@"windowController"];
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
			NSLog(@"Class: %@", NSStringFromClass(prinClass));
			NSObject <TrazzlePlugIn> *plugin = [[prinClass alloc] 
				initWithPlugInController:m_pluginController];
			NSLog(@"%@", plugin);
			[m_loadedPlugins addObject:plugin];
			[plugin release];
		}
	}
}

@end