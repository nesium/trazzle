//
//  NSRuleEditorDarkBackground.m
//  Trazzle
//
//  Created by Marc Bauer on 20.01.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "PredicateEditorDarkBackground.h"

@interface PredicateEditorDarkBackground (Private)
- (NSCompoundPredicate *)_validPredicate:(NSCompoundPredicate *)sourcePredicate;
@end


@implementation PredicateEditorDarkBackground

- (void)drawRect:(NSRect)aRect
{
	float rowHeight = [self numberOfRows] * [self rowHeight];
	rowHeight = aRect.size.height < rowHeight ? aRect.size.height : rowHeight;
	NSRect rowsRect = aRect;
	rowsRect.size.height = rowHeight;
	
	[[NSColor grayColor] drawSwatchInRect:aRect];
	[[NSColor controlHighlightColor] drawSwatchInRect:rowsRect];
	[super drawRect: rowsRect];
}

- (BOOL)_wantsRowAnimations
{
	return NO;
}

- (void)_postRowCountChangedNotificationOfType:(int)fp8 indexes:(id)fp12
{
	[self setNeedsDisplay];
	[(id)super _postRowCountChangedNotificationOfType: fp8 indexes: fp12];
}

- (void)setObjectValue:(id)object
{
	if ([object isMemberOfClass:[NSPredicate class]] || 
		[object isMemberOfClass:[NSComparisonPredicate class]])
	{
		object = [NSCompoundPredicate orPredicateWithSubpredicates:
			[NSArray arrayWithObject:object]];
	}
	/* 
	* There is a problem with not-predicates and predicate string representation.
	* @see http://www.cocoabuilder.com/archive/message/cocoa/2008/6/27/211281
	*/
	else if ([object isKindOfClass:[NSCompoundPredicate class]])
	{
		object = [self _validPredicate:object];
	}
	[super setObjectValue:object];
}

- (NSCompoundPredicate *)_validPredicate:(NSCompoundPredicate *)sourcePredicate
{
	BOOL needsTransform = NO;
	NSMutableArray *transformedSubpredicates = [NSMutableArray array];
	for (NSPredicate *subPredicate in [sourcePredicate subpredicates])
	{
		if ([subPredicate isKindOfClass:[NSCompoundPredicate class]])
		{
			NSCompoundPredicate *transformedSubPredicate = 
				[self _validPredicate:(NSCompoundPredicate *)subPredicate];
			[transformedSubpredicates addObject:transformedSubPredicate];
			needsTransform = needsTransform || transformedSubPredicate != subPredicate || 
				([sourcePredicate compoundPredicateType] == NSNotPredicateType && 
				[(NSCompoundPredicate *)subPredicate compoundPredicateType] != NSOrPredicateType);
		}
		else
		{
			[transformedSubpredicates addObject:subPredicate];
		}
	}
	if (!needsTransform)
	{
		return sourcePredicate;
	}
	if ([sourcePredicate compoundPredicateType] == NSNotPredicateType)
	{
		return (NSCompoundPredicate *)[NSCompoundPredicate notPredicateWithSubpredicate:
			[NSCompoundPredicate orPredicateWithSubpredicates:transformedSubpredicates]];
	}
	return [[[NSCompoundPredicate alloc] initWithType:[sourcePredicate compoundPredicateType] 
		subpredicates:transformedSubpredicates] autorelease];
}

@end