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

+ (SimpleMessage *)messageWithString:(NSString *)msgString
{
	SimpleMessage *msg = [[SimpleMessage alloc] init];
	msg.message = msgString;
	return [msg autorelease];
}

- (void)dealloc
{
	[m_message release];
	[super dealloc];
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	if (name == "message")
	{
		return YES;
	}
	return NO;
}

+ (NSString *)webScriptNameForKey:(const char *)name
{
	if (name == "m_message")
		return @"message";
	return nil;
}

@end