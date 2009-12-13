//
//  LPFilterController.m
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPFilterController.h"

@interface LPFilterController (Private)
- (void)_updateSelection;
@end


@implementation LPFilterController

@synthesize model=m_model;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super initWithWindowNibName:@"FilterEditor"]){
		SelectedFilterToIconTransformer *transformer = [[SelectedFilterToIconTransformer alloc]
			initWithFilterController:self];
		[NSValueTransformer setValueTransformer:transformer 
			forName:@"SelectedFilterToIconTransformer"];
		[transformer release];
	}
	return self;
}

- (void)windowDidLoad{
	NSMenu *mainMenu = [NSApp mainMenu];
	NSMenuItem *mainMenuItem = [[NSMenuItem alloc] init];
	[m_mainMenu setTitle:@"Filters"];
	[mainMenuItem setSubmenu:m_mainMenu];
	[mainMenu insertItem:mainMenuItem atIndex:3];
	[mainMenuItem release];
	
	m_mainMenuController = [[NSMMenuController alloc] initWithMenu:m_mainMenu];
	m_mainMenuController.insertionIndex = 6;
	m_mainMenuController.titleKey = @"name";
	m_mainMenuController.defaultAction = @selector(selectFilter:);
	m_mainMenuController.defaultTarget = self;
	[m_mainMenuController setContent:m_filterMenuArrayController];
	
	[m_filtersTable setTarget:self];
	[m_filtersTable setDoubleAction:@selector(filtersTable_doubleAction:)];
	
	[self _updateSelection];
}

- (BOOL)windowShouldClose:(id)window{
	[m_model save];
	return YES;
}

- (void)dealloc{
	[m_mainMenuController setContent:nil];
	[m_mainMenuController release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setModel:(LPFilterModel *)model{
	if (m_model == model) return;
	if (m_model){
		[m_model removeObserver:self forKeyPath:@"activeFilter"];
		[m_model removeObserver:self forKeyPath:@"filteringIsEnabled"];
	}
	m_model = model;
	[m_model addObserver:self forKeyPath:@"activeFilter" options:0 context:NULL];
	[m_model addObserver:self forKeyPath:@"filteringIsEnabled" options:0 context:NULL];
	[self _updateSelection];
}



#pragma mark -
#pragma mark Private methods

- (void)_updateSelection{
	[m_filterMenuArrayController setSelectedObjects:(m_model.activeFilter == nil 
		? nil 
		: [NSArray arrayWithObject:m_model.activeFilter])];
	[m_filteringIsEnabledMenuItem setState:(m_model.filteringIsEnabled ? NSOnState : NSOffState)];
	[m_filtersTable reloadData];		
}



#pragma mark -
#pragma mark KVO notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context{
	[self _updateSelection];
}



#pragma mark -
#pragma mark Action methods

- (void)selectFilter:(id)sender{
	m_model.activeFilter = (LPFilter *)[sender representedObject];
}

- (IBAction)editFilters:(id)sender{
	[[self window] makeKeyAndOrderFront:self];
}

- (IBAction)toggleFilteringIsEnabled:(id)sender{
	m_model.filteringIsEnabled = !m_model.filteringIsEnabled;
}

- (IBAction)add:(id)sender{
	[m_model addNewFilter];
}

- (IBAction)duplicate:(id)sender{
	if ([m_filterArrayController selectionIndex] == NSNotFound)
		return;
	[m_model duplicateFilter:[[m_filterArrayController selectedObjects] objectAtIndex:0]];
}

- (IBAction)remove:(id)sender{
	if ([m_filterArrayController selectionIndex] == NSNotFound)
		return;
	[m_model removeFilter:[[m_filterArrayController selectedObjects] objectAtIndex:0]];
}



#pragma mark -
#pragma mark FiltersTable target methods

- (void)filtersTable_doubleAction:(id)sender{
	if ([m_filtersTable clickedColumn] != 0){
		[m_filtersTable editColumn:[m_filtersTable clickedColumn] row:[m_filtersTable clickedRow] 
			withEvent:nil select:YES];
		return;
	}
	m_model.activeFilter = [[m_filterArrayController arrangedObjects] 
		objectAtIndex:[m_filtersTable clickedRow]];
	m_model.filteringIsEnabled = YES;
}
@end