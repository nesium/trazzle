//
//  WindowController.m
//  Trazzle
//
//  Created by Marc Bauer on 03.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ZZWindowController.h"
#import "TrazzlePlugIn.h"


@implementation ZZWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		m_delegates = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_delegates release];
	[super dealloc];
}

- (void)windowDidLoad
{
	while ([m_tabView numberOfTabViewItems])
	{
		[m_tabView removeTabViewItem:[m_tabView tabViewItemAtIndex:0]];
	}
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	ZZTabStyle *tabStyle = [[ZZTabStyle alloc] init];
	[m_tabBar setStyle:tabStyle];
	[tabStyle release];
	[m_tabBar setDisableTabClose:YES];
}

- (void)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate
{
	NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:ident];
	[tabViewItem setLabel:[delegate titleForTabWithIdentifier:ident]];
	[tabViewItem setView:view];
	[m_tabView addTabViewItem:tabViewItem];
	[tabViewItem release];
	[m_delegates addObject:delegate];
}



#pragma mark -
#pragma mark NSResponder methods

- (void)keyDown:(NSEvent *)event
{
	NSTabViewItem *selectedTab = [m_tabView selectedTabViewItem];
	uint32_t selectedIndex = [m_tabView indexOfTabViewItem:selectedTab];
	id delegate = [m_delegates objectAtIndex:selectedIndex];
	id consumed = NO;
	if ([delegate respondsToSelector:@selector(receivedKeyDown:inTabWithIdentifier:)])
	{
		consumed = objc_msgSend(delegate, @selector(receivedKeyDown:inTabWithIdentifier:), event, 
			[selectedTab identifier]);
	}
	if (!consumed)
	{
		[super keyDown:event];
	}
}

- (void)keyUp:(NSEvent *)event
{
	NSTabViewItem *selectedTab = [m_tabView selectedTabViewItem];
	uint32_t selectedIndex = [m_tabView indexOfTabViewItem:selectedTab];
	id delegate = [m_delegates objectAtIndex:selectedIndex];
	id consumed = NO;
	if ([delegate respondsToSelector:@selector(receivedKeyUp:inTabWithIdentifier:)])
	{
		consumed = objc_msgSend(delegate, @selector(receivedKeyUp:inTabWithIdentifier:), event, 
			[selectedTab identifier]);
	}
	if (!consumed)
	{
		[super keyUp:event];
	}
}

@end