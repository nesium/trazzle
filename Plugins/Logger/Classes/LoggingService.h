//
//  LoggingService.h
//  Logger
//
//  Created by Marc Bauer on 06.03.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>
#import "LogMessage.h"
#import "StackTraceItem.h"
#import "MessageParser.h"


@interface LoggingService : NSObject
{
	id m_delegate;
}
- (id)initWithDelegate:(id)delegate;
@end

@interface FlashLogMessage : NSObject
{
	NSString *message;
	BOOL encodeHTML;
	NSString *stacktrace;
	NSString *levelName;
	NSTimeInterval timestamp;
	uint32_t stackIndex;
	NSObject *complexObject;
}
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) BOOL encodeHTML;
@property (nonatomic, retain) NSString *stacktrace;
@property (nonatomic, retain) NSString *levelName;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) uint32_t stackIndex;
@property (nonatomic, retain) NSObject *complexObject;
@end

@interface NSObject (LoggingServiceDelegate)
- (void)loggingService:(LoggingService *)service didReceiveLogMessage:(LogMessage *)message 
	fromGateway:(AMFRemoteGateway *)gateway;
- (void)loggingService:(LoggingService *)service didReceivePNG:(NSString *)path withSize:(NSSize)size
	fromGateway:(AMFRemoteGateway *)gateway;
@end