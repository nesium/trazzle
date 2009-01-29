//
//  ConnectionSignature.m
//  Trazzle
//
//  Created by Marc Bauer on 09.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ConnectionSignature.h"


@implementation ConnectionSignature

@synthesize startTime=m_startTime;
@synthesize language=m_language;

- (void)dealloc
{
	[m_language release];
	[m_startTime release];
	[super dealloc];
}

@end