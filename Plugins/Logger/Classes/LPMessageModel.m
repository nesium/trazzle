//
//  MessageModel.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LPMessageModel.h"

@interface LPMessageModel (Private)
- (void)_validateMessages;
- (NSPredicate *)_applicablePredicate:(NSPredicate *)sourcePredicate 
	forMessage:(AbstractMessage *)message;
- (BOOL)_expression:(NSExpression *)expression isApplicableToMessage:(AbstractMessage *)message;
- (BOOL)_evaluateMessage:(AbstractMessage *)message;
- (void)_clearMessagesWithType:(LPMessageType)type;
@end


@implementation LPMessageModel

@synthesize delegate=m_delegate, 
			filter=m_filter, 
			showsFlashLogMessages=m_showsFlashLogMessages, 
			lastLogMessageTimestamp=m_lastLogMessageTimestamp;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_messages = [[NSMutableArray alloc] init];
		m_messageIndex = 0;
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
	if (m_filter == filter)
	{
		return;
	}
	[filter retain];
	if (m_filter) [m_filter removeObserver:self forKeyPath:@"predicate"];
	[m_filter release];
	m_filter = filter;
	[m_filter addObserver:self forKeyPath:@"predicate" options:0 context:NULL];
	[self _validateMessages];
}

- (void)addMessage:(AbstractMessage *)message
{
	// record timestamp of last message actively sent from flash
	if (message.messageType != kLPMessageTypeFlashLog && 
		message.messageType != kLPMessageTypeException){
		m_lastLogMessageTimestamp = [NSDate timeIntervalSinceReferenceDate];
	}
	message.visible = [self _evaluateMessage:message];
	message.index = m_messageIndex++;
	[m_messages addObject:message];
}

- (AbstractMessage *)messageWithIndex:(uint32_t)index
{
	for (AbstractMessage *msg in m_messages)
		if (msg.index == index)
			return msg;
	return nil;
}

- (void)clearAllMessages
{
	[m_messages removeAllObjects];
	m_messageIndex = 0;
}

- (void)clearFlashLogMessages
{
	[self _clearMessagesWithType:kLPMessageTypeFlashLog];
}

- (void)clearLogMessages
{
	[self _clearMessagesWithType:kLPMessageTypeSocket];
}

- (NSUInteger)numberOfMessages
{
	return [m_messages count];
}

- (void)setShowsFlashLogMessages:(BOOL)bFlag
{
	if (m_showsFlashLogMessages == bFlag) return;
	m_showsFlashLogMessages = bFlag;
	[self _validateMessages];
}



#pragma mark -
#pragma mark Private methods

- (void)_validateMessages
{
	NSMutableArray *invisibleMessagesDelta = [[NSMutableArray alloc] init];
	NSMutableArray *visibleMessagesDelta = [[NSMutableArray alloc] init];
	uint32_t i = 0;
	for (AbstractMessage *message in m_messages)
	{
		BOOL messageWasVisible = message.visible;
		BOOL messageShouldBeVisible = [self _evaluateMessage:message];
		
		if (messageWasVisible != messageShouldBeVisible)
		{
			message.visible = messageShouldBeVisible;
			if (messageShouldBeVisible) [visibleMessagesDelta addObject:[NSNumber numberWithInt:i]];
			else [invisibleMessagesDelta addObject:[NSNumber numberWithInt:i]];
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

- (NSPredicate *)_applicablePredicate:(NSPredicate *)sourcePredicate 
	forMessage:(AbstractMessage *)message
{
	if (sourcePredicate == nil)
	{
		return nil;
	}
	else if ([sourcePredicate isKindOfClass:[NSCompoundPredicate class]])
	{
		NSCompoundPredicate *comp = (NSCompoundPredicate *)sourcePredicate;
		NSMutableArray *applicableSubPredicates = [NSMutableArray array];
		BOOL needsTransform = NO;
		for (NSPredicate *subpredicate in [comp subpredicates])
		{
			if ([subpredicate isKindOfClass:[NSCompoundPredicate class]])
			{
				NSCompoundPredicate *applicableCompoundPredicate = 
					(NSCompoundPredicate *)[self _applicablePredicate:subpredicate forMessage:message];
				if (applicableCompoundPredicate != nil)
				{
					[applicableSubPredicates addObject:applicableCompoundPredicate];
					needsTransform = needsTransform || (applicableCompoundPredicate != subpredicate);
				}
				else needsTransform = YES;
			}
			else if ([subpredicate isKindOfClass:[NSComparisonPredicate class]])
			{
				NSComparisonPredicate *compa = (NSComparisonPredicate *)subpredicate;
				if ([self _expression:[compa leftExpression] isApplicableToMessage:message])
					[applicableSubPredicates addObject:compa];
				else needsTransform = YES;
			}
			else
			{
				NSLog(@"WARNING! Encountered unknown (sub)predicate type!");
			}
		}
		if (!needsTransform) return sourcePredicate;
		return [[[NSCompoundPredicate alloc] initWithType:[comp compoundPredicateType] 
			subpredicates:applicableSubPredicates] autorelease];
	}
	else if ([sourcePredicate isKindOfClass:[NSComparisonPredicate class]])
	{
		return [self _expression:[(NSComparisonPredicate *)sourcePredicate leftExpression] 
			isApplicableToMessage:message] ? sourcePredicate : nil;
	}
	else
	{
		NSLog(@"WARNING! Encountered unknown predicate type!");
		return nil;
	}
}

- (BOOL)_expression:(NSExpression *)expression isApplicableToMessage:(AbstractMessage *)message
{
	return [message respondsToSelector:NSSelectorFromString([expression keyPath])];
}

- (BOOL)_evaluateMessage:(AbstractMessage *)message
{
	if (!m_showsFlashLogMessages && message.messageType == kLPMessageTypeFlashLog)
		return NO;
	if (m_filter == nil)
		return YES;
	
	NSPredicate *predicate = [self _applicablePredicate:m_filter.predicate forMessage:message];
	return (predicate == nil) ? YES : [predicate evaluateWithObject:message];
}

- (void)_clearMessagesWithType:(LPMessageType)type
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSMutableArray *indexesArray = [NSMutableArray array];
	uint32_t count = [m_messages count];
	for (uint32_t i = 0; i < count; i++)
	{
		AbstractMessage *msg = [m_messages objectAtIndex:i];
		if (msg.messageType == type)
		{
			[indexes addIndex:i];
			[indexesArray addObject:[NSNumber numberWithInt:i]];
		}
	}
	[m_messages removeObjectsAtIndexes:indexes];
	if ([m_delegate respondsToSelector:@selector(messageModel:didRemoveMessagesWithIndexes:)])
		[m_delegate messageModel:self didRemoveMessagesWithIndexes:indexesArray];
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