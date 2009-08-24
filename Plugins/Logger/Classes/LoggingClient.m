//
//  LoggingServer.m
//  Logger
//
//  Created by Marc Bauer on 01.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LoggingClient.h"

#define kLoggerReadMessageTag 1

@interface LoggingClient (Private)
- (void)_continueReading;
@end


@implementation LoggingClient

@synthesize delegate=m_delegate, 
			signature=m_signature;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithSocket:(AsyncSocket *)socket
{
	if (self = [super init])
	{
		m_socket = [socket retain];
		[m_socket setDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	m_socket = nil;
	[m_signature release];
	m_signature = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)disconnect
{
	[m_socket disconnectAfterWriting];
}

- (void)sendString:(NSString *)msg
{
	NSData *data = [[msg stringByAppendingString:@"\0"] dataUsingEncoding:NSUTF8StringEncoding];
	[m_socket writeData:data withTimeout:-1 tag:0];
}

- (void)sendEventWithType:(NSString *)type attributes:(NSDictionary *)attributes
{
	NSMutableString *node = [NSMutableString stringWithFormat:@"<event type='%@'", type];
	for (NSString *key in attributes)
	{
		[node appendFormat:@" %@='%@'", key, [attributes objectForKey:key]];
	}
	[node appendString:@"/>"];
	[self sendString:node];
}



#pragma mark -
#pragma mark Private methods

- (void)_continueReading
{
	[m_socket readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:kLoggerReadMessageTag];	
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[self _continueReading];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *message = [NSString stringWithUTF8String:[data bytes]];
	if ([m_delegate respondsToSelector:@selector(client:didReceiveMessage:)])
	{
		[m_delegate client:self didReceiveMessage:message];
	}
	[self _continueReading];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if ([m_delegate respondsToSelector:@selector(clientDidDisconnect:)])
	{
		[m_delegate clientDidDisconnect:self];
	}
}



#pragma mark -
#pragma mark FileMonitor Delegate methods

- (void)fileMonitor:(FileMonitor *)fm fileDidChangeAtPath:(NSString *)path
{
	[self performSelectorOnMainThread:@selector(sendString:) 
		withObject:[NSString stringWithFormat:@"<event type=\"fileChange\" path=\"%@\"/>", path] 
		waitUntilDone:NO];
}

@end