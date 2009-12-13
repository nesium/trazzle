//
//  LPFilterModel.m
//  Logger
//
//  Created by Marc Bauer on 22.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPFilterModel.h"

@interface LPFilterModel (Private)
- (NSString *)_filtersPath;
- (void)_loadFilters;
- (void)_loadPreferences;
- (BOOL)_containsFilterWithName:(NSString *)name;
- (NSString *)_nextAvailableFilterName:(NSString *)baseName;
- (NSPredicate *)_defaultPredicate;
- (void)_saveDirtyFilters;
- (void)_saveFilter:(LPFilter *)filter;
- (void)_destroyFilter:(LPFilter *)filter;
@end


@implementation LPFilterModel

static NSMutableArray *g_filters = nil;
@synthesize activeFilter=m_activeFilter, 
			filteringIsEnabled=m_filteringIsEnabled, 
			showsFlashLogMessages=m_showsFlashLogMessages;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super init]){
		if (!g_filters){
			g_filters = [[NSMutableArray alloc] init];
			[self _loadFilters];
		}
		[self _loadPreferences];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(applicationWillTerminate:)
			name:NSApplicationWillTerminateNotification object:nil];
	}
	return self;
}

- (void)dealloc{
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)save{
	[self _saveDirtyFilters];
}

- (NSArray *)filters{
	return g_filters;
}

- (void)setShowsFlashLogMessages:(BOOL)bFlag{
	if (m_showsFlashLogMessages == bFlag) return;
	[[[NSUserDefaultsController sharedUserDefaultsController]
	  values] setValue:[NSNumber numberWithBool:bFlag] forKey:kShowFlashLogMessages];
	m_showsFlashLogMessages = bFlag;
}

- (LPFilter *)addNewFilter{
	LPFilter *filter = [[LPFilter alloc] initWithName:[self _nextAvailableFilterName:nil] 
		predicate:[self _defaultPredicate]];
	[self _saveFilter:filter];
	[self addFilter:filter];
	return [filter autorelease];
}

- (void)addFilter:(LPFilter *)aFilter{
	[self willChangeValueForKey:@"filters"];
	[g_filters addObject:aFilter];
	[self didChangeValueForKey:@"filters"];
}

- (void)removeFilter:(LPFilter *)aFilter{
	[self willChangeValueForKey:@"filters"];
	[aFilter retain];
	[g_filters removeObject:aFilter];
	if (aFilter == m_activeFilter){
		self.filteringIsEnabled = NO;
		self.activeFilter = [g_filters count] > 0 
			? [g_filters objectAtIndex:0]
			: nil;
	}
	[self _destroyFilter:aFilter];
	if ([g_filters count] == 0) self.filteringIsEnabled = NO;
	
	[self didChangeValueForKey:@"filters"];
}

- (LPFilter *)duplicateFilter:(LPFilter *)aFilter{
	LPFilter *filter = [[LPFilter alloc] initWithName:
		[self _nextAvailableFilterName:[aFilter.name stringByAppendingString:@" Copy"]] 
		predicate:[[aFilter.predicate copy] autorelease]];
	[self _saveFilter:filter];
	[self addFilter:filter];
	return [filter autorelease];
}

- (void)setActiveFilter:(LPFilter *)filter{
	if (filter == m_activeFilter)
		return;
	
	[self willChangeValueForKey:@"activeFilter"];
	[m_activeFilter release];
	m_activeFilter = [filter retain];
	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:(filter == nil) ? @"" : [filter path] forKey:kLastSelectedFilterKey];
	[self didChangeValueForKey:@"activeFilter"];
}

- (void)setFilteringIsEnabled:(BOOL)bFlag{
	if (m_filteringIsEnabled == bFlag)
		return;
	
	[self willChangeValueForKey:@"filteringIsEnabled"];
	m_filteringIsEnabled = bFlag;
	[[[NSUserDefaultsController sharedUserDefaultsController]
	  values] setValue:[NSNumber numberWithBool:bFlag] forKey:kFilteringEnabledKey];
	[self didChangeValueForKey:@"filteringIsEnabled"];
}



#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)aNotification{
	[self _saveDirtyFilters];
}



#pragma mark -
#pragma mark Private methods

- (BOOL)_containsFilterWithName:(NSString *)name{
	for (LPFilter *filter in g_filters)
		if ([[filter name] isEqualToString:name])
			return YES;
	return NO;
}

- (NSString *)_nextAvailableFilterName:(NSString *)baseName{
	if (baseName == nil) baseName = @"Untitled Filter";
	unsigned int i = 1;
	NSString *name;
	do name = [NSString stringWithFormat:@"%@ %d", baseName, i++];
	while ([self _containsFilterWithName:name]);
	return name;
}

- (NSString *)_filtersPath{
	return [TRAZZLE_APP_SUPPORT stringByAppendingPathComponent:@"Filters"];
}

- (void)_loadFilters{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSEnumerator *filesEnum = [[fm contentsOfDirectoryAtPath:[self _filtersPath] 
													   error: NULL] objectEnumerator];
	NSString *file;
	while (file = [filesEnum nextObject]){
		if (![[file pathExtension] isEqualToString:kFilterFileExtension])
			continue;
		
		NSError *error;
		NSString *filterPath = [[self _filtersPath] stringByAppendingPathComponent:file];
		LPFilter *filter = [[LPFilter alloc] initWithContentsOfFile:filterPath error:&error];
		if (filter == nil){
			NSLog(@"%@", [error description]);
			[filter release];
			continue;
		}
		[g_filters addObject:filter];
		[filter release];
	}
}

- (void)_loadPreferences{
	NSObject *defaultValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	NSString *selectedFilterPath = [defaultValues valueForKey:kLastSelectedFilterKey];
	BOOL foundSelectedFilter = NO;
	
	for (LPFilter *filter in g_filters){
		BOOL currentFilterIsSelected = [[filter path] isEqualToString:selectedFilterPath];
		if (currentFilterIsSelected){
			foundSelectedFilter = YES;
			[self setActiveFilter:filter];
			break;
		}
	}

	if (!foundSelectedFilter && [g_filters count] > 0)
		[self setActiveFilter:(LPFilter *)[g_filters objectAtIndex:0]];
	
	if ([[defaultValues valueForKey:kFilteringEnabledKey] boolValue] && [g_filters count] > 0)
		self.filteringIsEnabled = YES;
	
	self.showsFlashLogMessages = [[defaultValues valueForKey:kShowFlashLogMessages] boolValue];
}

- (void)_saveDirtyFilters{
	for (LPFilter *filter in g_filters){
		if (![filter isDirty]) continue;
		[self _saveFilter:filter];
	}
}

- (void)_saveFilter:(LPFilter *)filter{
	NSError *error;
	if (![filter save:&error])
		NSLog(@"%@", [error description]);
}

- (void)_destroyFilter:(LPFilter *)filter{
	NSError *error;
	if (![filter unlink:&error])
		NSLog(@"%@", [error description]);
}

- (NSPredicate *)_defaultPredicate{
	return [NSCompoundPredicate orPredicateWithSubpredicates: 
				[NSArray arrayWithObject:[NSComparisonPredicate 
					predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"level"]
					rightExpression:[NSExpression expressionForConstantValue:[NSNumber numberWithInt:0]]
					modifier:NSDirectPredicateModifier
					type:NSEqualToPredicateOperatorType
					options:NSCaseInsensitivePredicateOption]]];
}
@end