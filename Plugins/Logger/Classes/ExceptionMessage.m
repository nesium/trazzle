//
//  ExceptionMessage.m
//  Logger
//
//  Created by Marc Bauer on 13.03.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import "ExceptionMessage.h"


@implementation ExceptionMessage

@synthesize errorType, errorNumber;

- (id)init{
	if (self = [super init]){
		messageType = kLPMessageTypeException;
	}
	return self;
}

- (void)dealloc{
	[errorType release];
	[super dealloc];
}
@end