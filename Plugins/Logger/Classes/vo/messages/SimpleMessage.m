//
//  SimpleMessage.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SimpleMessage.h"


@implementation SimpleMessage

@synthesize message=m_message;
@synthesize timestamp=m_timestamp;

- (void)dealloc
{
	[m_message release];
	[super dealloc];
}

@end