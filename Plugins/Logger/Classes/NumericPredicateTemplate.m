//
//  NumericPredicateTemplate.m
//  Trazzle
//
//  Created by Marc Bauer on 18.12.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "NumericPredicateTemplate.h"


@interface NumericPredicateTemplate (Private)
- (double) matchForSubpredicate: (NSPredicate *) predicate;
- (NSPredicate *) modifiedPredicateForPredicate: (NSComparisonPredicate *) predicate;
@end


@implementation NumericPredicateTemplate


#pragma mark -
#pragma mark Overriden NSPredicateEditorRowTemplate methods

- (NSPredicate *) predicateWithSubpredicates: (NSArray *) subpredicates
{
	//SWLog(@"subpredicates: %@", self, _cmd, subpredicates);
    NSComparisonPredicate *predicate = 
		(NSComparisonPredicate *)[super predicateWithSubpredicates: subpredicates];
	//SWLog(@"predicate from super: %@", self, _cmd, [super predicateWithSubpredicates: subpredicates]);
	NSNumber *number = [NSNumber numberWithInt: [[[predicate rightExpression] 
		constantValue] intValue]];
    return [NSComparisonPredicate predicateWithLeftExpression: [predicate leftExpression] 
		rightExpression: [NSExpression expressionForConstantValue: number] 
		modifier: [predicate comparisonPredicateModifier] type: [predicate predicateOperatorType] 
		options: [predicate options]];
}

- (double) matchForPredicate: (NSPredicate *) predicate
{
	//SWLog(@"try to match %@ (%@)", self, _cmd, predicate, [predicate className]);
	//SWLog(@"super result: %d", self, _cmd, [super matchForPredicate: predicate]);

	if (![predicate isKindOfClass: [NSComparisonPredicate class]])
	{
		return 0;
	}

	if ([predicate isKindOfClass: [NSComparisonPredicate class]])
	{
		return [self matchForSubpredicate: predicate];
	}
	
	return 0;
}

// this is only called if we returned a value greater than zero in matchForPredicate, so we did
// all validation before and assume the RuleEditor passes a NSComparisonPredicate or a 
// NSCompoundPredicate in
- (void) setPredicate: (NSPredicate *) predicate
{
	[super setPredicate: [self modifiedPredicateForPredicate: (NSComparisonPredicate *)predicate]];
}




#pragma mark -
#pragma mark Private methods

- (double) matchForSubpredicate: (NSPredicate *) predicate
{
	@try
	{
		NSString *keyPath = [[(NSComparisonPredicate *)predicate leftExpression] keyPath];
		//SWLog(@"%@", self, _cmd, [(NSComparisonPredicate *)predicate leftExpression]);
		if ([keyPath isEqualToString: @"level"])
		{
			return 1.0;
		}
	}
	@catch (NSException *e)
	{
		//SWLog(@"caught exception %@", self, _cmd, e);
		return 0;
	}
	return 0;
}

- (NSPredicate *) modifiedPredicateForPredicate: (NSComparisonPredicate *) predicate
{
	NSExpression *modifiedRightExpression =  [NSExpression expressionForConstantValue: 
		[[[predicate rightExpression] constantValue] stringValue]];
	
	NSPredicate *modifiedPredicate = [NSComparisonPredicate 
		predicateWithLeftExpression: [predicate leftExpression] 
		rightExpression: modifiedRightExpression
		modifier: [predicate comparisonPredicateModifier] 
		type: [predicate predicateOperatorType] 
		options: [predicate options]];
		
	return modifiedPredicate;
}

@end