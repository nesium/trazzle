//
//  SystemMessage.m
//  Trazzle
//
//  Created by Marc Bauer on 13.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SystemMessage.h"


@implementation SystemMessage

@synthesize message=m_message;

- (void)dealloc
{
	[m_message release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[SystemMessage] %@", m_message];
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