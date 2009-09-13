//
//  PMMonitoringService.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 13.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PMMonitoringService.h"


@implementation PMMonitoringService

- (id)initWithDelegate:(id)delegate
{
	if (self = [super init])
	{
		m_delegate = delegate;
	}
	return self;
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway startMonitoring:(NSNumber *)maxFPS
{
	if ([m_delegate respondsToSelector:@selector(service:startMonitoring:forRemote:)])
		[m_delegate service:self startMonitoring:maxFPS forRemote:gateway];
}

- (oneway void)gateway:(AMFRemoteGateway *)gateway trackFPS:(NSNumber *)fps 
	memoryUse:(NSNumber *)memory timestamp:(NSNumber *)timestamp
{
	if ([m_delegate respondsToSelector:@selector(service:trackFPS:memoryUse:timestamp:forRemote:)])
		[m_delegate service:self trackFPS:fps memoryUse:memory timestamp:timestamp forRemote:gateway];
}

- (oneway void)gatewayStopMonitoring:(AMFRemoteGateway *)gateway
{
	if ([m_delegate respondsToSelector:@selector(serviceStopMonitoring:forRemote:)])
		[m_delegate serviceStopMonitoring:self forRemote:gateway];
}
@end