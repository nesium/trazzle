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
#import "LPExistingFilesCache.h"

@interface LogMessage : StackTraceItem{
	NSString *levelName;
	uint32_t level;
	BOOL encodeHTML;
	NSArray *stacktrace;
	NSTimeInterval connectionTimestamp;
	BOOL fileExists;
	BOOL m_didLookupFile;
}
@property (nonatomic, retain) NSString *levelName;
@property (nonatomic, readonly) uint32_t level;
@property (nonatomic, retain) NSArray *stacktrace;
@property (nonatomic, assign) BOOL encodeHTML;
@property (nonatomic, assign) NSTimeInterval connectionTimestamp;
@property (nonatomic, readonly) BOOL fileExists;
- (NSString *)formattedTimestamp;
@end