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
- (NSPredicate *)_applicablePredicate:(NSPredicate *)sourcePredicate 
	forMessage:(AbstractMessage *)message;
- (BOOL)_expression:(NSExpression *)expression isApplicableToMessage:(AbstractMessage *)message;
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
	if (m_filter == nil)
	{
		message.visible = YES;
	}
	else
	{
		NSPredicate *predicate = [self _applicablePredicate:m_filter.predicate forMessage:message];
		message.visible = (predicate == nil) ? YES : [predicate evaluateWithObject:message];
	}
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
	NSMutableArray *invisibleMessagesDelta = [NSMutableArray array];
	NSMutableArray *visibleMessagesDelta = [NSMutableArray array];
	uint32_t i = 0;
	for (AbstractMessage *message in m_messages)
	{
		BOOL messageWasVisible = message.visible;
		BOOL messageShouldBeVisible;
		NSPredicate *predicate = [[self _applicablePredicate:m_filter.predicate forMessage:message] retain];
		messageShouldBeVisible = (predicate == nil) ? YES : [predicate evaluateWithObject:message];
		if (messageWasVisible != messageShouldBeVisible)
		{
			message.visible = messageShouldBeVisible;
			if (messageShouldBeVisible) [visibleMessagesDelta addObject:[NSNumber numberWithInt:i]];
			else [invisibleMessagesDelta addObject:[NSNumber numberWithInt:i]];
		}
		i++;
		[predicate release];
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