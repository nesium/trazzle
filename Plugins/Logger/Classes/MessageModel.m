//
//  MessageModel.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "MessageModel.h"

@interface MessageModel (Private)
- (void)_validateMessages;
@end


@implementation MessageModel

@synthesize delegate=m_delegate, filter=m_filter;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_messages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_messages release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setFilter:(LPFilter *)filter
{
	[filter retain];
	if (m_filter) [m_filter removeObserver:self forKeyPath:@"predicate"];
	[m_filter release];
	m_filter = filter;
	[m_filter addObserver:self forKeyPath:@"predicate" options:0 context:NULL];
}

- (void)addMessage:(AbstractMessage *)message
{
	message.index = [m_messages count];
	[m_messages addObject:message];
}

- (AbstractMessage *)messageAtIndex:(uint32_t)index
{
	if (index > [m_messages count])
	{
		return nil;
	}
	return [m_messages objectAtIndex:index];
}

- (void)clearAllMessages
{
	[m_messages removeAllObjects];
}



#pragma mark -
#pragma mark Private methods

- (void)_validateMessages
{
	NSMutableIndexSet *invisibleMessagesDelta = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *visibleMessagesDelta = [NSMutableIndexSet indexSet];
	uint32_t i = 0;
	for (AbstractMessage *message in m_messages)
	{
		BOOL messageWasVisible = message.visible;
		BOOL messageShouldBeVisible = [m_filter.predicate evaluateWithObject:message];
		if (messageWasVisible != messageShouldBeVisible)
		{
			message.visible = messageShouldBeVisible;
			if (messageShouldBeVisible) [visibleMessagesDelta addIndex:i];
			else [invisibleMessagesDelta addIndex:i];
		}
		i++;
	}
	if ([invisibleMessagesDelta count] > 0 && 
		[m_delegate respondsToSelector:@selector(messageModel:didHideMessagesWithIndexes:)])
	{
		[m_delegate messageModel:self didHideMessagesWithIndexes:invisibleMessagesDelta];
	}
	if ([visibleMessagesDelta count] > 0 && 
		[m_delegate respondsToSelector:@selector(messageModel:didShowMessagesWithIndexes:)])
	{
		[m_delegate messageModel:self didShowMessagesWithIndexes:visibleMessagesDelta];
	}
	[invisibleMessagesDelta release];
	[visibleMessagesDelta release];
}



#pragma mark -
#pragma mark Bindings notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
	change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"predicate"])
	{
		[self _validateMessages];
	}
}

@end