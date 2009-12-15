//
//  NSPointerArray+LPAdditions.m
//  Logger
//
//  Created by Marc Bauer on 30.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSPointerArray+LPAdditions.h"


@implementation NSPointerArray (LPAdditions)

- (NSUInteger)aa_indexOfPointer:(void *)ptr{
	NSUInteger i = 0;
	for (i = 0; i < [self count]; i++)
	{
		void *ourPtr = [self pointerAtIndex:i];
		if (ourPtr == ptr)
			return i;
	}
	return NSNotFound;
}

- (BOOL)aa_containsPointer:(void *)ptr{
	return [self aa_indexOfPointer:ptr] != NSNotFound;
}

- (void)aa_removePointer:(void *)ptr{
	NSUInteger index = [self aa_indexOfPointer:ptr];
	if (index == NSNotFound)
		return;
	[self removePointerAtIndex:index];
}
@end