//
//  MessageModel.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

@synthesize delegate=m_delegate;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_messages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_messages release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (AbstractMessage *)messageAtIndex:(uint32_t)index
{
	if (index > [m_messages count])
	{
		return nil;
	}
	return [m_messages objectAtIndex:index];
}

@end