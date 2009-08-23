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
- (id <TrazzleTabViewDelegate>)_delegateForTabViewItem:(NSTabViewItem *)item;
- (void)_updateTabViewItemLabels;
- (void)_showWindowIfDelegatesAreReady;
@end

@interface NSObject (ZZWindowControllerPrivate)
- (id)_customFieldEditorForWindow:(NSWindow *)window;
@end

@implementation ZZWindowController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithWindowNibName:(NSString *)windowNibName delegate:(id)delegate
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		m_delegate = delegate;
		m_delegates = [[NSMutableArray alloc] init];
		m_windowIsReady = NO;
		m_windowWasVisible = NO;
		m_lastSelectedTabViewItem = nil;
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
	[m_tabBar setDelegate:self];
}



#pragma mark -
#pragma mark Public methods

- (IBAction)showWindow:(id)sender
{
	if (!m_windowIsReady) return;
	if (m_windowWasVisible)
	{
		[super showWindow:sender];
		return;
	}
	
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
	
	m_windowWasVisible = YES;
}

- (void)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate
{
	[m_delegates addObject:delegate];
	NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:ident];
	[tabViewItem setLabel:[delegate titleForTabWithIdentifier:ident]];
	[tabViewItem setView:view];
	[m_tabView addTabViewItem:tabViewItem];
	[tabViewItem release];
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

- (id <TrazzleTabViewDelegate>)_delegateForTabViewItem:(NSTabViewItem *)item
{
	return [m_delegates objectAtIndex:[m_tabView indexOfTabViewItem:item]];
}

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
	m_windowIsReady = YES;
	[self showWindow:self];
}



#pragma mark -
#pragma mark TabView delegate methods

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	id <TrazzleTabViewDelegate> delegate;
	if (m_lastSelectedTabViewItem != nil)
	{
		delegate = [self _delegateForTabViewItem:m_lastSelectedTabViewItem];
		if ([(NSObject *)delegate respondsToSelector:@selector(didBecomeInactive)])
			objc_msgSend(delegate, @selector(didBecomeInactive));
	}
	delegate = [self _delegateForTabViewItem:tabViewItem];
	if ([(NSObject *)delegate respondsToSelector:@selector(didBecomeActive)])
		objc_msgSend(delegate, @selector(didBecomeActive));
	m_lastSelectedTabViewItem = tabViewItem;
	if ([m_delegate respondsToSelector:@selector(windowController:didSelectTabViewDelegate:)])
		[m_delegate windowController:self didSelectTabViewDelegate:delegate];
}



#pragma mark -
#pragma mark Window delegate methods

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if ([anObject respondsToSelector:@selector(_customFieldEditorForWindow:)])
		return [(NSObject *)anObject _customFieldEditorForWindow:sender];
	return nil;
}



#pragma mark -
#pragma mark NSResponder methods

- (void)keyDown:(NSEvent *)event
{
	NSTabViewItem *selectedTab = [m_tabView selectedTabViewItem];
	uint32_t selectedIndex = [m_tabView indexOfTabViewItem:selectedTab];

	if ([event modifierFlags] & NSShiftKeyMask && 
		[event modifierFlags] & NSCommandKeyMask && 
		([event keyCode] == 123 || [event keyCode] == 124))
	{
		if ([m_tabView numberOfTabViewItems] == 0) return;
		if ([event keyCode] == 124) // right
		{
			if (selectedIndex == [m_tabView numberOfTabViewItems] - 1)
				[m_tabView selectFirstTabViewItem:self];
			else
				[m_tabView selectNextTabViewItem:self];
		}
		else if ([event keyCode] == 123) // left
		{
			if (selectedIndex == 0)
				[m_tabView selectLastTabViewItem:self];
			else
				[m_tabView selectPreviousTabViewItem:self];
		}
		return;
	}
	
	id delegate = [m_delegates objectAtIndex:selectedIndex];
	id consumed = NO;
	if ([delegate respondsToSelector:@selector(receivedKeyDown:inTabWithIdentifier:window:)])
	{
		consumed = objc_msgSend(delegate, @selector(receivedKeyDown:inTabWithIdentifier:window:), 
			event, [selectedTab identifier], [self window]);
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
	if ([delegate respondsToSelector:@selector(receivedKeyUp:inTabWithIdentifier:window:)])
	{
		consumed = objc_msgSend(delegate, @selector(receivedKeyUp:inTabWithIdentifier:window:), event, 
			[selectedTab identifier], [self window]);
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