//
//  NSMMenuController.m
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSMMenuController.h"

#define kNSMMCObservationContext @"NSMMCObservationContext"

@interface NSMMenuController (Private)
- (void)_createMenuItemsFromData:(NSArray *)data;
- (void)_removeMenuItemsWithData:(NSArray *)data;
- (void)_sortMenuItems;
- (void)_setNeedsInvalidation;
- (void)_setSelectedIndexes:(NSIndexSet *)indexes;
@end

@implementation NSMMenuController

@synthesize insertionIndex=m_insertionIndex, titleKey=m_titleKey, defaultAction=m_defaultAction, 
	defaultTarget=m_defaultTarget;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithMenu:(NSMenu *)menu
{
	if (self = [super init])
	{
		m_menu = [menu retain];
		m_insertionIndex = 0;
		m_arrayController = nil;
		m_menuItems = [[NSMutableArray alloc] init];
		m_content = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_titleKey release];
	[m_menu release];
	[m_menuItems release];
	[m_content release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setContent:(NSArrayController *)controller
{
	if (m_arrayController != nil)
	{
		[m_arrayController removeObserver:self forKeyPath:@"arrangedObjects"];
		[m_arrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	}
		
	m_arrayController = controller;	
	if (m_arrayController == nil) return;
	
	[controller addObserver:self forKeyPath:@"arrangedObjects" 
					options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
					context:kNSMMCObservationContext];
	[controller addObserver:self forKeyPath:@"selectionIndexes" options:0 
					context:kNSMMCObservationContext];
	
	NSArray *content = [controller arrangedObjects];
	if ([content count] > 0)
	{
		m_content = [content copy];
		[self _createMenuItemsFromData:content];
		[self _setNeedsInvalidation];
		[self _setSelectedIndexes:[controller valueForKey:@"selectionIndexes"]];
	}
}



#pragma mark -
#pragma mark Private methods

- (void)_createMenuItemsFromData:(NSArray *)data
{
	for (id item in data)
	{
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[item valueForKey:m_titleKey] 
			action:nil keyEquivalent:@""];
		[menuItem setAction:m_defaultAction];
		[menuItem setTarget:m_defaultTarget];
		[menuItem setRepresentedObject:item];
		[m_menuItems addObject:menuItem];
		[menuItem release];
		[self _setNeedsInvalidation];
	}
}

- (void)_removeMenuItemsWithData:(NSArray *)data
{
	NSArray *menuItemsCopy = [m_menuItems copy];
	for (NSMenuItem *menuItem in menuItemsCopy)
	{
		if ([data containsObject:[menuItem representedObject]])
		{
			[m_menuItems removeObject:menuItem];
			[m_menu removeItem:menuItem];
		}
	}
	[menuItemsCopy release];
}

- (void)_sortMenuItems
{
	NSArray *menuItemsCopy = [m_menuItems copy];
	uint32_t i = 0;
	for (NSMenuItem *menuItem in menuItemsCopy)
	{
		uint32_t index = [m_content indexOfObject:[menuItem representedObject]];
		if (i++ == index)
		{
			continue;
		}
		[menuItem retain];
		[m_menuItems removeObjectAtIndex:(i - 1)];
		[m_menuItems insertObject:menuItem atIndex:index];
		[menuItem release];
	}
	[menuItemsCopy release];
}

- (void)_setNeedsInvalidation
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(_invalidate) withObject:nil afterDelay:0.0];
}

- (void)_invalidate
{
	for (NSMenuItem *menuItem in m_menuItems)
	{
		if ([menuItem menu] != nil)
		{
			[m_menu removeItem:menuItem];
		}
	}
	uint32_t i = m_insertionIndex;
	for (NSMenuItem *menuItem in m_menuItems)
	{
		[m_menu insertItem:menuItem atIndex:i++];
	}
}

- (void)_setSelectedIndexes:(NSIndexSet *)indexes
{
	for (uint32_t i = 0; i < [m_menuItems count]; i++)
	{
		NSMenuItem *item = [m_menuItems objectAtIndex:i];
		[item setState:[indexes containsIndex:i] ? NSOnState : NSOffState];
	}
}



#pragma mark -
#pragma mark KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context
{
	if (context != kNSMMCObservationContext)
    {
		return;
	}
	
	if ([keyPath isEqualToString:@"arrangedObjects"])
	{
		NSArray *newContent = [[object valueForKeyPath:keyPath] retain];

		if (m_content == nil)
		{
			m_content = [newContent copy];
			[self _createMenuItemsFromData:newContent];
			[self _setNeedsInvalidation];
			return;
		}
		
		NSMutableArray *newItems = [newContent mutableCopy];
		[newItems removeObjectsInArray:m_content];
		[self _createMenuItemsFromData:newItems];
		[newItems release];
		
		NSMutableArray *removedItems = [m_content mutableCopy];
		[removedItems removeObjectsInArray:newContent];
		[self _removeMenuItemsWithData:removedItems];
		[removedItems release];
		
		[m_content release];
		m_content = [newContent copy];
		[newContent release];
		[self _sortMenuItems];
		[self _setNeedsInvalidation];
	}
	else if ([keyPath isEqualToString:@"selectionIndexes"])
	{
		[self _setSelectedIndexes:[object valueForKey:@"selectionIndexes"]];
	}
}

@end