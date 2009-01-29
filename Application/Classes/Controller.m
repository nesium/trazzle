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
		m_pluginController = [[PlugInController alloc] init];
		[m_pluginController setValue:m_windowController forKey:@"windowController"];
		[self loadPlugins];
	}
	return self;
}

- (void)awakeFromNib
{
	m_windowController = [[WindowController alloc] initWithWindowNibName:@"MainWindow"];
	[m_windowController showWindow:self];
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
 
		NSLog(@"%@", [pluginBundle principalClass]);
		Class prinClass;
		if (prinClass = [pluginBundle principalClass]/* && 
			[prinClass isSubclassOfClass:[AbstractPlugin class]]*/)
		{
			NSLog(@"Class: %@", NSStringFromClass(prinClass));
			AbstractPlugin *plugin = [[prinClass alloc] init];
			plugin.plugInController = m_pluginController;
			NSLog(@"%@", plugin);
			[m_loadedPlugins addObject:plugin];
			[plugin release];
		}
	}
}

@end