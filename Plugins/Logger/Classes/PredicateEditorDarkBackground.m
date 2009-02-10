//
//  NSRuleEditorDarkBackground.m
//  Trazzle
//
//  Created by Marc Bauer on 20.01.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "PredicateEditorDarkBackground.h"


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
	if (![object isKindOfClass:[NSCompoundPredicate class]] && 
		[object isKindOfClass:[NSPredicate class]])
	{
		object = [NSCompoundPredicate orPredicateWithSubpredicates:
			[NSArray arrayWithObject:object]];
	}
	/* 
	* this is a hack! the problem here is, that if you create a not-compoundpredicate from a string
	* appkit would parse the first subpredicate as a NSComparisonPredicate (if the not-compound-
	* predicate would have only one subpredicate). the problem with that behaviour is, that the
	* predicateeditor doesn't like not-compoundpredicates with a comparisonpredicates (actually
	* it does not find any template, throwing a exception), so we prepare those ones here ...
	*/
	else if ([object isKindOfClass:[NSCompoundPredicate class]] && 
		[(NSCompoundPredicate *)object compoundPredicateType] == NSNotPredicateType)
	{
		NSPredicate *firstSubPredicate = (NSPredicate *)[[(NSCompoundPredicate *)object 
			subpredicates] objectAtIndex:0];
		if (![firstSubPredicate isKindOfClass:[NSCompoundPredicate class]])
		{
			object = [NSCompoundPredicate notPredicateWithSubpredicate:
				[NSCompoundPredicate orPredicateWithSubpredicates:
					[NSArray arrayWithObject:firstSubPredicate]]];
		}
		else
		{
			NSLog(@"compound predicate type: %d", [(NSCompoundPredicate *)firstSubPredicate 
				compoundPredicateType]);
			NSLog([[[(NSCompoundPredicate *)firstSubPredicate subpredicates] objectAtIndex:0] 
				className]);
		}
	}
	[super setObjectValue:object];
}

@end