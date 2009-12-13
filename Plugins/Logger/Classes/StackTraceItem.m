//
//  StackTraceItem.m
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "StackTraceItem.h"


@implementation StackTraceItem

@synthesize fullClassName, shortClassName, method, file, line;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super init]){
		messageType = kLPMessageTypeStackTrace;
		line = -1;
	}
	return self;
}

- (void)dealloc{
	[fullClassName release];
	[shortClassName release];
	[method release];
	[file release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setFullClassName:(NSString *)aClassName{
	[aClassName retain];
	[fullClassName release];
	fullClassName = aClassName;
	[shortClassName release];
	NSArray *parts = [aClassName componentsSeparatedByString:@"."];
	shortClassName = (NSString *)[[parts objectAtIndex:[parts count] - 1] retain];
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name{
	if (name == "fullClassName" ||
		name == "shortClassName" ||
		name == "file" ||
		name == "method" ||
		name == "className" ||
		name == "line"){
		return NO;
	}
	return [super isKeyExcludedFromWebScript:name];
}
@end