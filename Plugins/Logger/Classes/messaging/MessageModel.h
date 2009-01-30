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
#import "SimpleMessage.h"


@interface MessageModel : NSObject 
{
	id m_delegate;

	AsyncSocket *m_socket;
	NSMutableArray *m_connectedClients;
	NSTask *m_tailTask;
	NSPipe *m_logPipe;
}
@property (nonatomic, assign) id delegate;
- (void)startListening;
@end


@interface NSObject (MessageModelExtensions)
- (void)messageModel:(MessageModel *)model didReceiveMessage:(id)message;
@end