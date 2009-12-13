//
//  ZZCoreService.m
//  Trazzle
//
//  Created by Marc Bauer on 13.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZCoreService.h"


@implementation ZZCoreService

- (id)initWithDelegate:(id)delegate{
	if (self = [super init]){
		m_delegate = delegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway setConnectionParams:(NSDictionary *)params{
	if ([m_delegate respondsToSelector:@selector(coreService:didReceiveConnectionParams:fromGateway:)])
		[m_delegate coreService:self didReceiveConnectionParams:params fromGateway:gateway];
}
@end