//
//  LogMessage.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "LogMessage.h"

@implementation LogMessage

@synthesize levelName, level, stacktrace, encodeHTML, index, connectionTimestamp;
static NSArray *kLPLogLevels;

#pragma mark -
#pragma mark Initialization & deallocation

+ (void)initialize
{
	kLPLogLevels = [[NSArray alloc] initWithObjects: @"not specified", @"temp", 
		@"debug", @"info", @"notice", @"warning", @"error", @"critical", @"fatal", @"exception", nil];
}

- (id)init
{
	if (self = [super init])
	{
		encodeHTML = YES;
		messageType = kLPMessageTypeSocket;
		m_didLookupFile = NO;
	}
	return self;
}

- (void)dealloc
{
	[levelName release];
	[stacktrace release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setLevelName:(NSString *)aLevel
{
	[aLevel retain];
	[levelName release];
	if ([aLevel isEqualToString:@""])
	{
		[aLevel release];
		aLevel = [[kLPLogLevels objectAtIndex:0] retain];
	}
	levelName = aLevel;
	level = [[NSNumber numberWithInt:[kLPLogLevels indexOfObject:aLevel]] intValue];
	levelName = aLevel;
}

- (NSString *)message
{
	return encodeHTML ? [message htmlEncodedStringWithConvertedLinebreaks] : message;
}

- (NSString *)formattedTimestamp
{
	BOOL useRelativeTimestamp = YES;
	NSTimeInterval interval = useRelativeTimestamp
		? timestamp
		: timestamp + connectionTimestamp;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
	return [date descriptionWithCalendarFormat:@"%M:%S:%F" timeZone:nil locale:nil];
}

- (BOOL)fileExists
{
	if (!m_didLookupFile)
	{
		m_fileExists = [[LPExistingFilesCache sharedCache] fileExistsAtPath:file];
		m_didLookupFile = YES;
	}
	return m_fileExists;
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	if (name == "levelName" ||
		name == "connectionTimestamp" ||
		name == "message" ||
		name == "stacktrace" ||
		name == "index" ||
		name == "timestamp" || 
		name == "formattedTimestamp" || 
		name == "fileExists")
	{
		return NO;
	}
	return [super isKeyExcludedFromWebScript:name];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
	return !(sel == @selector(formattedTimestamp));
}

@end