//
//  IPInspectionService.h
//  Inspector
//
//  Created by Marc Bauer on 17.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>


@interface IPInspectionService : NSObject{
	NSObject *m_delegate;
}
- (id)initWithDelegate:(id)aDelegate;
@end


@interface NSObject (IPInspectionServiceDelegate)
- (void)inspectionService:(IPInspectionService *)service shouldInspectObject:(id)anObject 
	forGateway:(AMFRemoteGateway *)gateway;
@end