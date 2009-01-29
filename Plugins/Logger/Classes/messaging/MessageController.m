//
//  MessageController.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "MessageController.h"


@implementation MessageController

- (id)init
{
	if (self = [super init])
	{
		m_messageModel = [[MessageModel alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_messageModel release];
	[super dealloc];
}

@end