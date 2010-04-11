//
//  ZZCoreService.h
//  Trazzle
//
//  Created by Marc Bauer on 13.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>


@interface ZZCoreService : NSObject{
	id m_delegate;
}
@end

@interface NSObject (ZZCoreServiceDelegate)
- (void)coreService:(ZZCoreService *)service didReceiveConnectionParams:(NSDictionary *)params
	fromGateway:(AMFRemoteGateway *)gateway;
@end