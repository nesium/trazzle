//
//  FDBConnection.h
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "FDBMessage.h"


@interface FDBConnection : NSObject
{
	AsyncSocket *m_socket;
}
+ (FDBConnection *)connectionWithSocket:(AsyncSocket *)socket;
- (id)initWithSocket:(AsyncSocket *)socket;
@end