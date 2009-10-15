//
//  FileObservingService.h
//  Logger
//
//  Created by Marc Bauer on 15.10.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDuplexGateway.h"


@interface FileObservingService : NSObject
{
	id m_delegate;
}
- (id)initWithDelegate:(id)delegate;
@end

@interface NSObject (FileObservingServiceDelegate)
- (void)fileObservingService:(FileObservingService *)service 
	didReceiveObservingMessageForPath:(NSString *)aPath 
	shouldStopObserving:(BOOL)shouldStop 
	fromGateway:(AMFRemoteGateway *)gateway;
@end