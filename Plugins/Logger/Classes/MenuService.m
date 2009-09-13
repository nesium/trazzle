//
//  MenuService.m
//  Logger
//
//  Created by Marc Bauer on 16.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "MenuService.h"

@interface MenuService (Private)
- (NSMenu *)_menuFromSWFMenu:(SWFMenu *)aMenu target:(id)target;
@end


@implementation MenuService

- (id)initWithDelegate:(id)delegate
{
	if (self = [super init])
	{
		m_delegate = delegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway setMenu:(SWFMenu *)aMenu
{
	if ([m_delegate respondsToSelector:@selector(menuService:didReceiveMenu:fromGateway:)])
		[m_delegate menuService:self 
			didReceiveMenu:[self _menuFromSWFMenu:aMenu target:m_delegate] 
			fromGateway:gateway];
}



#pragma mark -
#pragma mark Private methods

- (NSMenu *)_menuFromSWFMenu:(SWFMenu *)aMenu target:(id)target
{
	if (aMenu == nil || (id)aMenu == [NSNull null]) return nil;
	NSMenu *menu = [[NSMenu alloc] init];
	for (SWFMenuItem *anItem in aMenu.menuItems)
	{
		NSMenuItem *item = [[NSMenuItem alloc] init];
		[item setTitle:anItem.title];
		[item setState:(anItem.selected ? NSOnState : NSOffState)];
		[item setSubmenu:[self _menuFromSWFMenu:anItem.submenu target:target]];
		[item setAction:@selector(statusMenuItemWasClicked:)];
		[item setTarget:target];
		[menu addItem:item];
		[item release];
	}
	return [menu autorelease];
}
@end



@implementation SWFMenu

@synthesize menuItems;

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		self.menuItems = [coder decodeObject];
	}
	return self;
}

- (void)dealloc
{
	[menuItems release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08x> menuItems: %@", [self className], (long)self, 
		menuItems];
}

@end


@implementation SWFMenuItem

@synthesize title, submenu, selected;

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		self.title = [coder decodeObject];
		self.submenu = [coder decodeObject];
		self.selected = [(AMFUnarchiver *)coder decodeBool];
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[submenu release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08x> title: %@, selected: %d, submenu: %@", [self className], 
			(long)self, title, selected, submenu];
}

@end