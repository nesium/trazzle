//
//  AbstractMessage.m
//  Logger
//
//  Created by Marc Bauer on 31.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AbstractMessage.h"


@implementation AbstractMessage

@synthesize messageType, index, message, timestamp, visible;

#pragma mark -
#pragma mark Initialization & Deallocation

+ (AbstractMessage *)messageWithType:(LPMessageType)type{
	AbstractMessage *message = [[[self class] alloc] init];
	message.messageType = type;
	return [message autorelease];
}

+ (AbstractMessage *)messageWithType:(LPMessageType)type message:(NSString *)messageString{
	AbstractMessage *message = [[self class] messageWithType:type];
	message.message = messageString;
	return message;
}

- (id)init{
	if (self = [super init]){
		index = 0;
		message = nil;
		timestamp = 0;
		visible = YES;
		messageType = kLPMessageTypeSystem;
	}
	return self;
}

- (void)dealloc{
	[message release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@: 0x%08X> type: %d, message: %@", 
		[self className], (long)self, messageType, message];
}



#pragma mark -
#pragma mark WebScripting Protocol

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name{
	if (name == "message" || 
		name == "timestamp" || 
		name == "messageType" || 
		name == "index" || 
		name == "visible"){
		return NO;
	}
	return YES;
}
@end