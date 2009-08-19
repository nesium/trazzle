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

- (oneway void)gateway:(AMFRemoteGateway *)gateway setConnectionParams:(NSDictionary *)params
{
	if ([m_delegate respondsToSelector:@selector(loggingService:didReceiveConnectionParams:fromGateway:)])
		[m_delegate loggingService:self didReceiveConnectionParams:params fromGateway:gateway];
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway log:(FlashLogMessage *)logMessage
{
	LogMessage *message = [[LogMessage alloc] init];
	message.message = logMessage.message;
	message.levelName = logMessage.levelName;
	message.timestamp = logMessage.timestamp;
	message.encodeHTML = logMessage.encodeHTML;
	
	if ([logMessage.stacktrace isKindOfClass:[NSString class]])
	{
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
	}
	
	if ([m_delegate respondsToSelector:@selector(loggingService:didReceiveLogMessage:fromGateway:)])
		[m_delegate loggingService:self didReceiveLogMessage:message fromGateway:gateway];
	
	[message release];
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway logPNG:(NSData *)pngData width:(NSNumber *)width
	height:(NSNumber *)height
{
	NSString *filename = [NSString stringWithFormat:@"/tmp/trazzle_%@.png", [NSObject uuid]];
	NSError *error;
	[pngData writeToFile:filename options:0 error:&error];
	[(LPRemoteGateway *)gateway addLoggedImagePath:filename];
	
	if ([m_delegate respondsToSelector:@selector(loggingService:didReceivePNG:withSize:fromGateway:)])
		[m_delegate loggingService:self didReceivePNG:filename 
			withSize:(NSSize){[width floatValue], [height floatValue]} fromGateway:gateway];
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway addI18NKey:(NSString *)key 
	toFile:(NSString *)path
{
	NSStringEncoding encoding;
	path = [path stringByExpandingTildeInPath];
	NSString *fileData = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:nil];
	NSMutableArray *lines = [NSMutableArray array];
	if (fileData != nil)
	{
		[lines addObjectsFromArray:[fileData componentsSeparatedByString:@"\n"]];
		if ([lines containsObject:key]) return;
	}
	[lines addObject:key];
	[lines sortUsingSelector:@selector(caseInsensitiveCompare:)];
	[[lines componentsJoinedByString:@"\n"] writeToFile:path atomically:NO encoding:encoding 
		error:nil];
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
