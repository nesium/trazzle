//
//  StackTraceItem.h
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StackTraceItem : NSObject
{
	NSString *m_fqClassName;
	NSString *m_className;
	NSString *m_method;
	NSString *m_file;
	NSUInteger m_line;
}

@property (nonatomic, retain) NSString *fqClassName;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, assign) NSUInteger line;

- (void)setFQClassName:(NSString *)clazz;
- (NSString *)fqClassName;
- (NSString *)className;

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name;

@end