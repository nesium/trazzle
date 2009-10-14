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

@interface LPMessageModel : NSObject
{
	id m_delegate;
	LPFilter *m_filter;
	NSMutableArray *m_messages;
	BOOL m_showsFlashLogMessages;
	uint32_t m_messageIndex;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) LPFilter *filter;
@property (nonatomic, assign) BOOL showsFlashLogMessages;
- (void)addMessage:(AbstractMessage *)message;
- (AbstractMessage *)messageWithIndex:(uint32_t)index;
- (void)clearAllMessages;
- (void)clearFlashLogMessages;
- (void)clearLogMessages;
- (NSUInteger)numberOfMessages;
@end


@interface NSObject (LPMessageModelDelegate)
// arrays instead of indexsets are used because they will be passed to javascript, which works 
// way better with arrays
- (void)messageModel:(LPMessageModel *)model didHideMessagesWithIndexes:(NSArray *)indexes;
- (void)messageModel:(LPMessageModel *)model didShowMessagesWithIndexes:(NSArray *)indexes;
- (void)messageModel:(LPMessageModel *)model didRemoveMessagesWithIndexes:(NSArray *)indexes;
- (void)messageModelDidResetMessageIds:(LPMessageModel *)model;
@end