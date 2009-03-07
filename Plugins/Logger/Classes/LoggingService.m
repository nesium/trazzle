//
//  LoggingService.m
//  Logger
//
//  Created by Marc Bauer on 06.03.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import "LoggingService.h"


@implementation LoggingService

@synthesize delegate=m_delegate;

- (id)initWithDelegate:(id)delegate
{
	if (self = [super init])
	{
		self.delegate = delegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway log:(FlashLogMessage *)logMessage
{
	LogMessage *message = [[LogMessage alloc] init];
	message.message = logMessage.message;
	message.levelName = logMessage.levelName;
	message.timestamp = logMessage.timestamp;
	message.encodeHTML = logMessage.encodeHTML;
	
	NSArray *stacktrace = [StackTraceParser parseAS3StackTrace:logMessage.stacktrace];
	if (logMessage.stackIndex >= 0 && logMessage.stackIndex < [stacktrace count])
	{
		StackTraceItem *item = [stacktrace objectAtIndex:logMessage.stackIndex];
		message.fullClassName = item.fullClassName;
		message.method = item.method;
		message.file = item.file;
		message.line = item.line;
	}
	else
		NSLog(@"warning! stacktrace index is out of bounds");

	stacktrace = [stacktrace subarrayWithRange:NSMakeRange(logMessage.stackIndex + 1, 
		[stacktrace count] - logMessage.stackIndex - 1)];
	
	if ([stacktrace	count])
		[message setStacktrace:stacktrace];
	
	if ([m_delegate respondsToSelector:@selector(loggingService:didReceiveLogMessage:fromGateway:)])
		[m_delegate loggingService:self didReceiveLogMessage:message fromGateway:gateway];
	
	[message release];
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway logPNG:(NSData *)pngData
{
	NSString *filename = [NSString stringWithFormat:@"/tmp/trazzle_%@.png", [pngData sha1HexHash]];
	NSError *error;
	[pngData writeToFile:filename options:0 error:&error];
	
	if ([m_delegate respondsToSelector:@selector(loggingService:didReceivePNG:fromGateway:)])
		[m_delegate loggingService:self didReceivePNG:filename fromGateway:gateway];
}
@end



@implementation FlashLogMessage

@synthesize message, encodeHTML, stacktrace, levelName, timestamp, stackIndex;

- (void)dealloc
{
	[message release];
	[stacktrace release];
	[levelName release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		self.message = [coder decodeObjectForKey:@"message"];
		self.encodeHTML = [coder decodeBoolForKey:@"encodeHTML"];
		self.stacktrace = [coder decodeObjectForKey:@"stacktrace"];
		self.levelName = [coder decodeObjectForKey:@"levelName"];
		self.timestamp = [coder decodeDoubleForKey:@"timestamp"] / 1000;
		self.stackIndex = [coder decodeInt32ForKey:@"stackIndex"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:message forKey:@"message"];
	[coder encodeBool:encodeHTML forKey:@"encodeHTML"];
	[coder encodeObject:stacktrace forKey:@"stacktrace"];
	[coder encodeObject:levelName forKey:@"levelName"];
	[coder encodeDouble:(timestamp * 1000) forKey:@"timestamp"];
	[coder encodeInt32:stackIndex forKey:@"stackIndex"];
}
@end
