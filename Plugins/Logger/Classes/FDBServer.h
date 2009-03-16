//
//  FDBServer.h
//  Logger
//
//  Created by Marc Bauer on 14.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "AMF.h"
#import "AMFUnarchiver.h"


@interface FDBServer : NSObject 
{
	AsyncSocket *m_socket;
}

@end