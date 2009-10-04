//
//  NSPointerArray+LPAdditions.h
//  Logger
//
//  Created by Marc Bauer on 30.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSPointerArray (LPAdditions)
- (NSUInteger)aa_indexOfPointer:(void *)ptr;
- (BOOL)aa_containsPointer:(void *)ptr;
- (void)aa_removePointer:(void *)ptr;
@end