//
//  LPFilter.h
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "ZZConstants.h"

@interface LPFilter : NSObject 
{
	NSString *m_name;
	NSString *m_path;
	NSPredicate *m_predicate;
	BOOL m_isDirty;
	BOOL m_wantsRenaming;
}

- (id)initWithName:(NSString *)name predicate:(NSPredicate *)predicate;
- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;

- (NSString *)name;
- (void)setName:(NSString *)name;
- (NSString *)path;
- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)predicate;
- (BOOL)isDirty;
- (BOOL)save:(NSError **)error;
- (BOOL)unlink:(NSError **)error;

@end