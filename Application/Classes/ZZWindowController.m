//
//  WindowController.m
//  Trazzle
//
//  Created by Marc Bauer on 03.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ZZWindowController.h"


@implementation ZZWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
	}
	return self;
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

- (void)addTabWithIdentifier:(id)ident title:(NSString *)title view:(NSView *)view
{
	NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:ident];
	[tabViewItem setLabel:title];
	[tabViewItem setView:view];
	[m_tabView addTabViewItem:tabViewItem];
	[tabViewItem release];
}



#pragma mark -
#pragma mark NSResponder methods

- (void)keyDown:(NSEvent *)event
{
}

- (void)keyUp:(NSEvent *)event
{
	
	// either webview or our window needs to be first responder so that we clear the output
//	if (([event keyCode] == 51 || [event keyCode] == 117) && 
//		(([firstResponder respondsToSelector:@selector(isDescendantOf:)] &&
//			[(NSView *)firstResponder isDescendantOf:m_webView]) || 
//			firstResponder == [self window]))
//	{
//		[m_logMessageModel clear];
//	}
}

@end