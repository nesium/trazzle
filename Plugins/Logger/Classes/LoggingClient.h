//
//  LoggingServer.h
//  Logger
//
//  Created by Marc Bauer on 01.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "FileMonitor.h"
#import "ConnectionSignature.h"

@interface LoggingClient : NSObject <FileObserver>
{
	AsyncSocket *m_socket;
	id m_delegate;
	ConnectionSignature *m_signature;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) ConnectionSignature *signature;

- (id)initWithSocket:(AsyncSocket *)socket;
- (void)disconnect;

- (void)sendString:(NSString *)msg;
- (void)sendEventWithType:(NSString *)type attributes:(NSDictionary *)attributes;
- (void)fileMonitor:(FileMonitor *)fm fileDidChangeAtPath:(NSString *)path;
@end

@interface NSObject (LoggingClientDelegate)
- (void)client:(LoggingClient *)client didReceiveMessage:(NSString *)message;
- (void)clientDidDisconnect:(LoggingClient *)client;
@end