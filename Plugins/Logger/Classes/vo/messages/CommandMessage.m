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

@synthesize type=m_type;
@synthesize attributes=m_attributes;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithAction:(NSString *)action attributes:(NSDictionary *)attributes
{
	self = [super init];
	self.type = [self commandActionTypeFromString:action];
	self.attributes = attributes;
	return self;
}

- (void)dealloc
{
	[m_attributes release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (CommandActionType)type
{
	return m_type;
}

- (NSDictionary *)attributes
{
	return m_attributes;
}



#pragma mark -
#pragma mark Private methods

- (CommandActionType)commandActionTypeFromString:(NSString *)type
{
	if ([type isEqualToString:@"clear"])
	{
		return kCommandActionTypeClear;
	}
	else if ([type isEqualToString:@"monitorFile"])
	{
		return kCommandActionTypeStartFileMonitoring;
	}
	else if ([type isEqualToString:@"unmonitorFile"])
	{
		return kCommandActionTypeStopFileMonitoring;
	}
	return kCommandActionTypeUnknown;
}

@end