//
//  CommandMessage.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CommandMessage.h"



@interface CommandMessage (Private)
- (CommandActionType)commandActionTypeFromString:(NSString *)type;
@end



@implementation CommandMessage

@synthesize type, attributes;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithAction:(NSString *)action attributes:(NSDictionary *)actionAttributes
{
	if (self = [super init])
	{
		self.attributes = actionAttributes;
		messageType = kLPMessageTypeCommand;
		type = [self commandActionTypeFromString:action];
	}
	return self;
}

- (void)dealloc
{
	[attributes release];
	[super dealloc];
}



#pragma mark -
#pragma mark Private methods

- (CommandActionType)commandActionTypeFromString:(NSString *)aType
{
	if ([aType isEqualToString:@"clear"])
	{
		return kCommandActionTypeClear;
	}
	else if ([aType isEqualToString:@"monitorFile"])
	{
		return kCommandActionTypeStartFileMonitoring;
	}
	else if ([aType isEqualToString:@"unmonitorFile"])
	{
		return kCommandActionTypeStopFileMonitoring;
	}
	return kCommandActionTypeUnknown;
}

@end