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

@interface LogMessage : StackTraceItem
{
	NSString *levelName;
	uint32_t level;
	BOOL encodeHTML;
	BOOL visible;
	NSArray *stacktrace;
	NSTimeInterval connectionTimestamp;
}

@property (nonatomic, retain) NSString *levelName;
@property (nonatomic, readonly) uint32_t level;
@property (nonatomic, retain) NSArray *stacktrace;
@property (nonatomic, assign) BOOL encodeHTML;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSTimeInterval connectionTimestamp;

- (NSString *)formattedTimestamp;

@end