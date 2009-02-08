//
//  LPFilterController.m
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPFilterController.h"

@interface LPFilterController (Private)
- (NSString *)_filtersPath;
- (void)_loadFilters;
@end


@implementation LPFilterController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super initWithWindowNibName:@"FilterEditor"])
	{
		m_filters = [[NSMutableArray alloc] init];
		[self _loadFilters];
		// load window
		[self window];
	}
	return self;
}

- (void)windowDidLoad
{
	NSMenu *mainMenu = [NSApp mainMenu];
	NSMenuItem *mainMenuItem = [[NSMenuItem alloc] init];
	[m_mainMenu setTitle:@"Filters"];
	[mainMenuItem setSubmenu:m_mainMenu];
	[mainMenu insertItem:mainMenuItem atIndex:2];
	[mainMenuItem release];
	
	m_mainMenuController = [[NSMMenuController alloc] initWithMenu:m_mainMenu];
	m_mainMenuController.insertionIndex = 5;
	m_mainMenuController.titleKey = @"name";
	[m_mainMenuController bind:@"content" toObject:m_filterArrayController 
		withKeyPath:@"arrangedObjects" options:nil];
}

- (void)dealloc
{
	[m_filters release];
	[super dealloc];
}



#pragma mark -
#pragma mark Private methods

- (NSString *)_filtersPath
{
	return [TRAZZLE_APP_SUPPORT stringByAppendingPathComponent:@"Filters"];
}

- (void)_loadFilters
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSEnumerator *filesEnum = [[fm contentsOfDirectoryAtPath:[self _filtersPath] 
		error: NULL] objectEnumerator];
	NSString *file;
	NSString *selectedFilterPath = [[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey: kLastSelectedFilterKey];
	BOOL foundSelectedFilter = NO;
	
	while (file = [filesEnum nextObject])
	{
		if (![[file pathExtension] isEqualToString:kFilterFileExtension])
		{
			continue;
		}
	
		NSString *filterPath = [[self _filtersPath] 
			stringByAppendingPathComponent:file];
		NSError *error;
		LPFilter *filter = [[LPFilter alloc] initWithContentsOfFile:filterPath error:&error];
		if (filter == nil)
		{
			NSLog([error description]);
			continue;
		}
		NSLog(@"%@", filter);
		[m_filters addObject:filter];
		BOOL currentFilterIsSelected = [[filter path] isEqualToString:selectedFilterPath];
		if (currentFilterIsSelected)
		{
			foundSelectedFilter = YES;
			//[self setActiveFilter:filter];
		}
	}
	
	if (!foundSelectedFilter && [m_filters count] > 0)
	{
		//[self setActiveFilter:(LPFilter *)[m_availableFilters objectAtIndex:0]];
	}
}

@end