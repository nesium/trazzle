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

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSPredicate *predicate;

- (id)initWithName:(NSString *)name predicate:(NSPredicate *)predicate;
- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;

- (NSString *)path;
- (BOOL)isDirty;
- (BOOL)save:(NSError **)error;
- (BOOL)unlink:(NSError **)error;

@end