//
//  IPInspectionService.m
//  Inspector
//
//  Created by Marc Bauer on 17.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "IPInspectionService.h"


@implementation IPInspectionService

- (id)initWithDelegate:(id)aDelegate
{
	if (self = [super init])
	{
		m_delegate = aDelegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway inspectObject:(NSObject *)obj 
	metadata:(NSObject *)metadata
{
	NSLog(@"%@", obj);
	NSLog(@"%@", metadata);
}
@end