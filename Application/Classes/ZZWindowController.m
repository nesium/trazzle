//
//  WindowController.m
//  Trazzle
//
//  Created by Marc Bauer on 03.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ZZWindowController.h"
#import "TrazzlePlugIn.h"

@interface ZZWindowController (Private)
- (void)_updateTabViewItemLabels;
- (void)_showWindowIfDelegatesAreReady;
@end

@implementation ZZWindowController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		m_delegates = [[NSMutableArray alloc] init];
		[self window];
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
	ZZTabStyle *tabStyle = [[ZZTabStyle alloc] init];
	[m_tabBar setStyle:tabStyle];
	[tabStyle release];
	[m_tabBar setDisableTabClose:YES];
}



#pragma mark -
#pragma mark Public methods

- (IBAction)showWindow:(id)sender
{
	NSWindow *win = [self window];
	[win setAlphaValue:0.0];
	[win makeKeyAndOrderFront:self];
	
	// that seems odd
	// if we do not resize the frame of the window, the webview of the loggerplugin shows 
	// scrollbars, which are not needed though
	NSRect frame = [win frame];
	frame.size.width += 1;
	[win setFrame:frame display:NO];
	frame.size.width -= 1;
	[win setFrame:frame display:YES];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.15];
	[[win animator] setAlphaValue:1.0];
	[NSAnimationContext endGrouping];
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
	[(NSObject *)delegate addObserver:self forKeyPath:@"tabTitle" options:0 context:NULL];
	[(NSObject *)delegate addObserver:self forKeyPath:@"isReady" options:0 context:NULL];
}

- (void)bringWindowToTop
{
	[[self window] orderFrontRegardless];
}

- (void)setWindowIsFloating:(BOOL)bFlag
{
	[[self window] setLevel:(bFlag ? NSFloatingWindowLevel : NSNormalWindowLevel)];
}



#pragma mark -
#pragma mark Private methods

- (void)_updateTabViewItemLabels
{
	for (int i = 0; i < [[m_tabView tabViewItems] count]; i++)
	{
		NSTabViewItem *item = [m_tabView tabViewItemAtIndex:i];
		id <TrazzleTabViewDelegate> delegate = [m_delegates objectAtIndex:i];
		[item setLabel:[delegate titleForTabWithIdentifier:[item identifier]]];
	}
}

- (void)_showWindowIfDelegatesAreReady
{
	for (NSObject *delegate in m_delegates)
		if (![[delegate valueForKey:@"isReady"] boolValue])
			return;
	[self showWindow:self];
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



#pragma mark -
#pragma mark KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"tabTitle"])
		[self _updateTabViewItemLabels];
	else if ([keyPath isEqualToString:@"isReady"])
		[self _showWindowIfDelegatesAreReady];
}

@end