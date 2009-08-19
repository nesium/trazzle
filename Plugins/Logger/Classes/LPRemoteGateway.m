//
//  LPRemoteGateway.m
//  Logger
//
//  Created by Marc Bauer on 16.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPRemoteGateway.h"


@implementation LPRemoteGateway

@synthesize connectionParams=m_connectionParams, 
			menuItem=m_menuItem, 
			loggedImages=m_loggedImages;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_loggedImages = nil;
		m_menuItem = nil;
		m_connectionParams = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_connectionParams release];
	[m_menuItem release];
	[m_loggedImages release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)addLoggedImagePath:(NSString *)aPath
{
	if (!m_loggedImages)
		m_loggedImages = [[NSMutableArray alloc] init];
	[m_loggedImages addObject:aPath];
}

@end