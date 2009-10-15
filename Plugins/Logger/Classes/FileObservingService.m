//
//  FileObservingService.m
//  Logger
//
//  Created by Marc Bauer on 15.10.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FileObservingService.h"


@implementation FileObservingService

- (id)initWithDelegate:(id)delegate
{
	if (self = [super init])
	{
		m_delegate = delegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway startObservingFile:(NSString *)path
{
	SEL selector = @selector(fileObservingService:didReceiveObservingMessageForPath:shouldStopObserving:fromGateway:);
	if ([m_delegate respondsToSelector:selector])
	{
		[m_delegate fileObservingService:self didReceiveObservingMessageForPath:path 
			shouldStopObserving:NO fromGateway:gateway];
	}
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway stopObservingFile:(NSString *)path
{
	SEL selector = @selector(fileObservingService:didReceiveObservingMessageForPath:shouldStopObserving:fromGateway:);
	if ([m_delegate respondsToSelector:selector])
	{
		[m_delegate fileObservingService:self didReceiveObservingMessageForPath:path 
			shouldStopObserving:YES fromGateway:gateway];
	}
}

@end