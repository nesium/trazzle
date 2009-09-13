//
//  PMPerformanceMonitorPlugin.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 11.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMPerformanceMonitorPlugin.h"


@implementation PMPerformanceMonitorPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_controller = aController;
		m_windowController = [[PMMainWindowController alloc] 
			initWithWindowNibName:@"MonitorWindow" plugInController:aController];
		[[m_controller sharedGateway] registerService:[[[PMMonitoringService alloc] 
			initWithDelegate:m_windowController] autorelease] withName:@"MonitoringService"];
	}
	return self;
}

- (void)trazzleDidCloseConnection:(ZZConnection *)conn
{
	[m_windowController removeLayerWithConnection:conn];
}

@end