//
//  PlugInController.m
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "PlugInController.h"
#import "ZZWindowController.h"


@interface PlugInController (Private)
- (void)_destroyStatusItem;
- (NSStatusItem *)_statusItem;
@end

NSStatusItem *m_statusItem;
NSBundle *m_plugInBundle;
ZZWindowController *m_windowController;



@implementation PlugInController

@synthesize sharedGateway=m_sharedGateway, 
			sharedLegacyConnection=m_sharedLegacyConnection, 
			connectedClients=m_connectedClients;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInBundle:(NSBundle *)bundle windowController:(ZZWindowController *)controller 
	gateway:(AMFDuplexGateway *)gateway legacyConnection:(AsyncSocket *)legacyConnection 
	connectedClients:(NSArray *)connectedClients
{
	if (self = [super init])
	{
		m_statusItem = nil;
		m_plugInBundle = [bundle retain];
		m_windowController = controller;
		m_sharedGateway = gateway;
		m_sharedLegacyConnection = legacyConnection;
		m_connectedClients = connectedClients;
	}
	return self;
}

- (void)dealloc
{
	[self _destroyStatusItem];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)bringWindowToTop
{
	[m_windowController bringWindowToTop];
}

- (void)setWindowIsFloating:(BOOL)bFlag
{
	[m_windowController setWindowIsFloating:bFlag];
}

- (id)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate
{
	return [m_windowController addTabWithIdentifier:ident view:view delegate:delegate];
}

- (void)selectTabItemWithDelegate:(id<TrazzleTabViewDelegate>)aDelegate
{
	[m_windowController selectTabItemWithDelegate:aDelegate];
}

- (id)selectedTabDelegate{
	return [m_windowController selectedTabDelegate];
}

- (void)addStatusMenuItem:(NSMenuItem *)item
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[[self _statusItem] menu] addItem:item];
}

- (void)removeStatusMenuItem:(NSMenuItem *)item
{
	[[[self _statusItem] menu] removeItem:item];
	if ([[[[self _statusItem] menu] itemArray] count] == 0)
	{
		[self performSelector:@selector(_destroyStatusItem) withObject:nil afterDelay:0.0];
	}
}

- (ZZConnection *)connectionForRemote:(id)remote
{
	for (ZZConnection *conn in m_connectedClients)
		if (conn.remote == remote)
			return conn;
	return nil;
}



#pragma mark -
#pragma mark Private methods

- (void)_destroyStatusItem
{
	if (!m_statusItem)
	{
		return;
	}
	[[NSStatusBar systemStatusBar] removeStatusItem:m_statusItem];
	[m_statusItem release];
	m_statusItem = nil;
}

- (NSStatusItem *)_statusItem
{
	if (!m_statusItem)
	{
		m_statusItem = [[[NSStatusBar systemStatusBar] 
			statusItemWithLength:NSSquareStatusItemLength] retain];
		[m_statusItem setImage:[NSImage imageNamed:@"statusbar_icon.png"]];
		[m_statusItem setAlternateImage:[NSImage imageNamed:@"statusbar_icon_alternate.png"]];
		[m_statusItem setHighlightMode:YES];
		NSMenu *menu = [[NSMenu alloc] init];
		[m_statusItem setMenu:menu];
		[menu release];
	}
	return m_statusItem;
}

@end