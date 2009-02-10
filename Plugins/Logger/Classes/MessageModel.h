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
#import "LPFilter.h"

@interface MessageModel : NSObject
{
	id m_delegate;
	LPFilter *m_filter;
	NSMutableArray *m_messages;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) LPFilter *filter;
- (void)addMessage:(AbstractMessage *)message;
- (AbstractMessage *)messageAtIndex:(uint32_t)index;
- (void)clearAllMessages;
@end


@interface NSObject (LPMessageModelDelegate)
- (void)messageModel:(MessageModel *)model didHideMessagesWithIndexes:(NSArray *)indexes;
- (void)messageModel:(MessageModel *)model didShowMessagesWithIndexes:(NSArray *)indexes;
@end