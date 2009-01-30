//
//  StackTraceItem.m
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "StackTraceItem.h"


@implementation StackTraceItem

@synthesize fqClassName=m_fqClassName;
@dynamic className;
@synthesize method=m_method;
@synthesize file=m_file;
@synthesize line=m_line;

#pragma mark -
#pragma mark Initialization & Deallocation

- (void)dealloc
{
	[m_fqClassName release];
	[m_className release];
	[m_method release];
	[m_file release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setFQClassName:(NSString *)clazz
{
	[clazz retain];
	[m_fqClassName release];
	m_fqClassName = clazz;
	[m_className release];
	NSArray *parts = [m_fqClassName componentsSeparatedByString:@"."];
	m_className = (NSString *)[[parts objectAtIndex:[parts count] - 1] retain];
}

- (NSString *)className
{
	return m_className;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: 0x%08X> className: %@, method: %@, file: %@, line: %d", 
		[self className], (long)self, m_className, m_method, m_file, m_line];
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	if (name == "fqClassName" ||
		name == "className" ||
		name == "file" ||
		name == "method" ||
		name == "className" ||
		name == "line")
	{
		return YES;
	}
	return NO;
}

+ (NSString *)webScriptNameForKey:(const char *)name
{
	if (name == "m_fqClassName")
		return @"fqClassName";
	if (name == "m_className")
		return @"className";
	if (name == "m_file")
		return @"file";
	if (name =="m_method")
		return @"method";
	if (name == "m_class")
		return @"className";
	if (name == "m_line")
		return @"line";

	return nil;
}

@end