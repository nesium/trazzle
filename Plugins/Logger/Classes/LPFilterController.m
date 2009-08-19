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
- (BOOL)_containsFilterWithName:(NSString *)name;
- (NSString *)_nextAvailableFilterName:(NSString *)baseName;
- (NSPredicate *)_defaultPredicate;
- (void)_saveDirtyFilters;
- (void)_saveFilter:(LPFilter *)filter;
- (void)_destroyFilter:(LPFilter *)filter;
@end


@implementation LPFilterController

@synthesize delegate=m_delegate, 
			activeFilter=m_activeFilter, 
			filteringIsEnabled=m_filteringIsEnabled;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithDelegate:(id)delegate
{
	if (self = [super initWithWindowNibName:@"FilterEditor"])
	{
		self.delegate = delegate;
		
		SelectedFilterToIconTransformer *transformer = [[SelectedFilterToIconTransformer alloc]
			initWithFilterController:self];
		[NSValueTransformer setValueTransformer:transformer 
			forName:@"SelectedFilterToIconTransformer"];
		[transformer release];
		
		m_filters = [[NSMutableArray alloc] init];
		m_filteringIsEnabled = NO;
		// load window
		[self window];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(applicationWillTerminate:)
			name:NSApplicationWillTerminateNotification object:nil];
	}
	return self;
}

- (void)windowDidLoad
{
	NSMenu *mainMenu = [NSApp mainMenu];
	NSMenuItem *mainMenuItem = [[NSMenuItem alloc] init];
	[m_mainMenu setTitle:@"Filters"];
	[mainMenuItem setSubmenu:m_mainMenu];
	[mainMenu insertItem:mainMenuItem atIndex:3];
	[mainMenuItem release];
	
	m_mainMenuController = [[NSMMenuController alloc] initWithMenu:m_mainMenu];
	m_mainMenuController.insertionIndex = 5;
	m_mainMenuController.titleKey = @"name";
	m_mainMenuController.defaultAction = @selector(selectFilter:);
	m_mainMenuController.defaultTarget = self;
	[m_mainMenuController setContent:m_filterMenuArrayController];
	
	[m_filterMenuArrayController setSelectedObjects:(m_activeFilter == nil ? nil 
		: [NSArray arrayWithObject:m_activeFilter])];
	[m_filteringIsEnabledMenuItem setState:(m_filteringIsEnabled ? NSOnState : NSOffState)];
	
	[m_filtersTable setTarget:self];
	[m_filtersTable setDoubleAction:@selector(filtersTable_doubleAction:)];
}

- (BOOL)windowShouldClose:(id)window
{
	[self _saveDirtyFilters];
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self _saveDirtyFilters];
}

- (void)dealloc
{
	[m_mainMenuController setContent:nil];
	[m_mainMenuController release];
	[m_filters release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)load
{
	[self _loadFilters];
}

- (void)setActiveFilter:(LPFilter *)filter
{
	if (filter == m_activeFilter)
		return;
	
	[m_activeFilter release];
	m_activeFilter = [filter retain];
	
	[m_filterMenuArrayController setSelectedObjects:(m_activeFilter == nil ? nil 
		: [NSArray arrayWithObject:m_activeFilter])];
	
	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:(filter == nil) ? @"" : [filter path] 
		forKey:kLastSelectedFilterKey];
	
	[m_filtersTable reloadData];
	
	if ([m_delegate respondsToSelector:@selector(filterController:didSelectFilter:)])
		[m_delegate filterController:self didSelectFilter:m_activeFilter];
}

- (void)setFilteringIsEnabled:(BOOL)bFlag
{
	if (m_filteringIsEnabled == bFlag)
		return;
	
	m_filteringIsEnabled = bFlag;
	[m_filtersTable reloadData];
	[m_filteringIsEnabledMenuItem setState:(bFlag ? NSOnState : NSOffState)];
	
	[[[NSUserDefaultsController sharedUserDefaultsController]
	  values] setValue:[NSNumber numberWithBool:bFlag] forKey:kFilteringEnabledKey];
	
	if ([m_delegate respondsToSelector:@selector(filterController:didChangeFilteringEnabledFlag:)])
		[m_delegate filterController:self didChangeFilteringEnabledFlag:m_filteringIsEnabled];
}



#pragma mark -
#pragma mark Action methods

- (void)selectFilter:(id)sender
{
	self.activeFilter = (LPFilter *)[sender representedObject];
}

- (IBAction)editFilters:(id)sender
{
	[[self window] makeKeyAndOrderFront:self];
}

- (IBAction)toggleFilteringIsEnabled:(id)sender
{
	self.filteringIsEnabled = !m_filteringIsEnabled;
}

- (IBAction)add:(id)sender
{
	LPFilter *filter = [[LPFilter alloc] initWithName:[self _nextAvailableFilterName:nil] 
		predicate:[self _defaultPredicate]];
	[m_filterArrayController addObject:filter];
	[self _saveFilter:filter];
	[filter release];
}

- (IBAction)duplicate:(id)sender
{
	if ([m_filterArrayController selectionIndex] == NSNotFound)
		return;

	LPFilter *selectedFilter = [[m_filterArrayController selectedObjects] objectAtIndex:0];
	LPFilter *filter = [[LPFilter alloc] initWithName:
			[self _nextAvailableFilterName:[selectedFilter.name stringByAppendingString:@" Copy"]] 
		predicate:[[selectedFilter.predicate copy] autorelease]];
	[m_filterArrayController addObject:filter];
	[self _saveFilter:filter];
	[filter release];
}

- (IBAction)remove:(id)sender
{
	if ([m_filterArrayController selectionIndex] == NSNotFound)
		return;
	
	LPFilter *filter = [[m_filterArrayController selectedObjects] objectAtIndex:0];
	[m_filterArrayController removeObject:filter];
	if (filter == m_activeFilter)
	{
		self.filteringIsEnabled = NO;
		self.activeFilter = [m_filters count] > 0 
			? [[m_filterArrayController arrangedObjects] objectAtIndex:0]
			: nil;
	}
	[self _destroyFilter:filter];
	if ([m_filters count] == 0) self.filteringIsEnabled = NO;
}



#pragma mark -
#pragma mark Private methods

- (BOOL)_containsFilterWithName:(NSString *)name
{
	for (LPFilter *filter in m_filters)
		if ([[filter name] isEqualToString:name])
			return YES;
	return NO;
}

- (NSString *)_nextAvailableFilterName:(NSString *)baseName
{
	if (baseName == nil) baseName = @"Untitled Filter";
	unsigned int i = 1;
	NSString *name;
	do name = [NSString stringWithFormat:@"%@ %d", baseName, i++];
	while ([self _containsFilterWithName:name]);
	return name;
}

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
		valueForKey:kLastSelectedFilterKey];
	BOOL foundSelectedFilter = NO;
	
	while (file = [filesEnum nextObject])
	{
		if (![[file pathExtension] isEqualToString:kFilterFileExtension])
			continue;
	
		NSString *filterPath = [[self _filtersPath] 
			stringByAppendingPathComponent:file];
		NSError *error;
		LPFilter *filter = [[LPFilter alloc] initWithContentsOfFile:filterPath error:&error];
		if (filter == nil)
		{
			NSLog([error description]);
			continue;
		}
		[m_filters addObject:filter];
		BOOL currentFilterIsSelected = [[filter path] isEqualToString:selectedFilterPath];
		if (currentFilterIsSelected)
		{
			foundSelectedFilter = YES;
			[self setActiveFilter:filter];
		}
	}
	
	if (!foundSelectedFilter && [m_filters count] > 0)
		[self setActiveFilter:(LPFilter *)[m_filters objectAtIndex:0]];
	
	if ([[[[NSUserDefaultsController sharedUserDefaultsController]
	  values] valueForKey:kFilteringEnabledKey] boolValue] && [m_filters count] > 0)
	{
		self.filteringIsEnabled = YES;
	}
}

- (void)_saveDirtyFilters
{
	for (LPFilter *filter in m_filters)
	{
		if (![filter isDirty]) continue;
		[self _saveFilter:filter];
	}
}

- (void)_saveFilter:(LPFilter *)filter
{
	NSError *error;
	if (![filter save:&error])
		NSLog([error description]);
}

- (void)_destroyFilter:(LPFilter *)filter
{
	NSError *error;
	if (![filter unlink:&error])
		NSLog([error description]);
}

- (NSPredicate *)_defaultPredicate
{
	return [NSCompoundPredicate orPredicateWithSubpredicates: 
				[NSArray arrayWithObject:[NSComparisonPredicate 
					predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"level"]
					rightExpression:[NSExpression expressionForConstantValue:[NSNumber numberWithInt:0]]
					modifier:NSDirectPredicateModifier
					type:NSEqualToPredicateOperatorType
					options:NSCaseInsensitivePredicateOption]]];
}



#pragma mark -
#pragma mark FiltersTable target methods

- (void)filtersTable_doubleAction:(id)sender
{
	if ([m_filtersTable clickedColumn] != 0)
	{
		[m_filtersTable editColumn:[m_filtersTable clickedColumn] 
							   row:[m_filtersTable clickedRow] 
						 withEvent:nil 
							select:YES];
		return;
	}
	self.activeFilter = [[m_filterArrayController arrangedObjects] 
						 objectAtIndex:[m_filtersTable clickedRow]];
	if (!m_filteringIsEnabled) self.filteringIsEnabled = YES;
}

@end