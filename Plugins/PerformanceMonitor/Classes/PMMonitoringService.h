//
//  PMMonitoringService.h
//  PerformanceMonitor
//
//  Created by Marc Bauer on 13.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>


@interface PMMonitoringService : NSObject
{
	id m_delegate;
}
- (id)initWithDelegate:(id)delegate;
@end

@interface NSObject (PMMonitoringServiceDelegate)
- (void)service:(PMMonitoringService *)service startMonitoring:(NSNumber *)maxFPS 
	forRemote:(AMFRemoteGateway *)remote;
- (void)service:(PMMonitoringService *)service trackFPS:(NSNumber *)fps memoryUse:(NSNumber *)memory 
	timestamp:(NSNumber *)timestamp forRemote:(AMFRemoteGateway *)remote;
- (void)serviceStopMonitoring:(PMMonitoringService *)service forRemote:(AMFRemoteGateway *)remote;
@end