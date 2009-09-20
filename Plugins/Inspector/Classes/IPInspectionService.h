//
//  IPInspectionService.h
//  Inspector
//
//  Created by Marc Bauer on 17.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDuplexGateway.h"


@interface IPInspectionService : NSObject
{
	id m_delegate;
}
- (id)initWithDelegate:(id)aDelegate;
@end