//
//  ConnectionSignature.m
//  Trazzle
//
//  Created by Marc Bauer on 09.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ConnectionSignature.h"


@implementation ConnectionSignature

@synthesize startTime, language, swfURL, applicationName;

- (id)init
{
	if (self = [super init])
	{
		messageType = kLPMessageTypeConnectionSignature;
	}
	return self;
}

- (void)dealloc
{
	[language release];
	[startTime release];
	[swfURL release];
	[applicationName release];
	[super dealloc];
}

@end