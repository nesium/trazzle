//
//  FDBConnection.h
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "FDBMessage.h"
#import "FDBSourceModule.h"


@interface FDBConnection : NSObject
{
	AsyncSocket *m_socket;
	uint32_t m_lastMessageType;
	uint32_t m_playerVersion;
	NSMutableArray *m_sourceFiles;
}
+ (FDBConnection *)connectionWithSocket:(AsyncSocket *)socket;
- (id)initWithSocket:(AsyncSocket *)socket;

- (void)setBreakpointAtFileWithId:(uint32_t)fileId line:(uint32_t)line;
- (void)resume;
- (void)stepContinue;
- (void)requestSWFInfo:(uint16_t)swfIndex;
@end