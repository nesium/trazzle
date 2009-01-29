//
//  LogMessage.h
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StackTraceItem.h"
#import "NSString+LPStringAdditions.h"

@class TraceSocketProxy;

@interface LogMessage : StackTraceItem
{
	NSString *m_levelName;
	NSUInteger m_level;
	NSString *m_message;
	BOOL m_encodeHTML;
	BOOL m_visible;
	NSArray *m_stacktrace;
	NSUInteger m_index;
	NSTimeInterval m_connectionTimestamp;
	NSTimeInterval m_timestamp;
}

@property (nonatomic, retain) NSString *levelName;
@property (nonatomic, readonly) NSUInteger level;
@property (nonatomic, retain) NSArray *stacktrace;
@property (nonatomic, assign) BOOL encodeHTML;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) NSTimeInterval connectionTimestamp;

- (void)setMessage:(NSString *)message;
- (NSString *)message;

- (NSString *)formattedTimestamp;

@end