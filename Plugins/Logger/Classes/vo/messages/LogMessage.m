//
//  LogMessage.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "LogMessage.h"


static NSArray *g_logLevels;


@implementation LogMessage

@dynamic levelName;
@synthesize level=m_level;
@synthesize stacktrace=m_stacktrace;
@synthesize encodeHTML=m_encodeHTML;
@synthesize index=m_index;
@synthesize visible=m_visible;
@synthesize timestamp=m_timestamp;
@synthesize connectionTimestamp=m_connectionTimestamp;


#pragma mark -
#pragma mark Initialization & deallocation

- (id)init
{
	self = [super init];
	if (!g_logLevels)
	{
		g_logLevels = [[NSArray alloc] initWithObjects: @"not specified", @"temp", @"debug", 
		@"info", @"notice", @"warning", @"error", @"critical", @"fatal", nil];
	}
	self.encodeHTML = YES;
	return self;
}

- (void)dealloc
{
	[m_levelName release];
	[m_message release];
	[m_stacktrace release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setLevelName:(NSString *)level
{
	[level retain];
	[m_levelName release];
	if ([level isEqualToString:@""])
	{
		level = [g_logLevels objectAtIndex:0];
	}
	m_level = [[NSNumber numberWithInt:[g_logLevels indexOfObject:level]] intValue];
	m_levelName = level;
}

- (NSString *)levelName
{
	return m_levelName;
}

- (void)setMessage:(NSString *)message
{
	[message retain];
	[m_message release];
	m_message = message;
}

- (NSString *)message
{
	return m_encodeHTML ? [m_message htmlEncodedStringWithConvertedLinebreaks] : m_message;
}

- (NSString *)formattedTimestamp
{
	BOOL useRelativeTimestamp = YES;
	NSTimeInterval interval = useRelativeTimestamp
		? m_timestamp
		: m_timestamp + m_connectionTimestamp;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
	return [date descriptionWithCalendarFormat:@"%M:%S:%F" timeZone:nil locale:nil];
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
		name == "timestamp")
	{
		return YES;
	}
	return [super isKeyExcludedFromWebScript:name];
}

@end