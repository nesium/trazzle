//
//  MessageModel.h
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "MessageParser.h"


@interface MessageModel : NSObject 
{
	AsyncSocket *m_socket;
	NSMutableArray *m_connectedClients;
	
	NSTask *m_tailTask;
	NSPipe *m_logPipe;
}

@end