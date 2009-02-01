//
//  MessageModel.h
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageParser.h"
#import "AbstractMessage.h"


@interface MessageModel : NSObject 
{
	id m_delegate;
	
	NSMutableArray *m_messages;
}
@property (nonatomic, assign) id delegate;
- (AbstractMessage *)messageAtIndex:(uint32_t)index;
@end