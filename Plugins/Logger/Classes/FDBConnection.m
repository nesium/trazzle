//
//  FDBConnection.m
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FDBConnection.h"

#define kReadDataLengthTag 1
#define kReadDataTag 2

@interface FDBConnection (Private)
- (void)_initConnection;
- (void)_continueReading;
- (void)_sendMessage:(FDBMessage *)msg;
- (void)_sendOptionMessage:(NSString *)option value:(NSString *)value;
- (void)_sendSquelch:(BOOL)bFlag;
@end

@implementation FDBConnection

+ (FDBConnection *)connectionWithSocket:(AsyncSocket *)socket
{
	return [[[FDBConnection alloc] initWithSocket:socket] autorelease];
}

- (id)initWithSocket:(AsyncSocket *)socket
{
	if (self = [super init])
	{
		m_socket = [socket retain];
		[m_socket setDelegate:self];
		NSLog(@"init");
		[self _initConnection];
	}
	return self;
}


#pragma mark -
#pragma mark Private methods

- (void)_initConnection
{
	NSLog(@"init connection");
	[self _sendOptionMessage:@"disable_script_stuck_dialog" value:@"on"];
	[self _sendOptionMessage:@"disable_script_stuck" value:@"on"];
	[self _sendOptionMessage:@"break_on_fault" value:@"on"];
	[self _sendOptionMessage:@"enumerate_override" value:@"on"];
	[self _sendOptionMessage:@"notify_on_failure" value:@"on"];
	[self _sendOptionMessage:@"invoke_setters" value:@"on"];
	[self _sendOptionMessage:@"swf_load_messages" value:@"on"];
	[self _sendOptionMessage:@"getter_timeout" value:kFDBPrefGetVarResponseTimeout];
	[self _sendOptionMessage:@"setter_timeout" value:kFDBPrefSetVarResponseTimeout];
	[self _sendSquelch:YES];
	[self _continueReading];
}

- (void)_sendMessage:(FDBMessage *)msg
{
	NSLog(@"send: %@", [msg messageData]);
	[m_socket writeData:[msg messageData] withTimeout:-1 tag:0];
}

- (void)_sendOptionMessage:(NSString *)option value:(NSString *)value
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSetOption];
	[msg encodeUTF:option];
	[msg encodeUTF:value];
	[self _sendMessage:msg];
}

- (void)_sendSquelch:(BOOL)bFlag
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSetSquelch];
	[msg encodeUnsignedInt:(bFlag ? 0 : 1)];
}

- (void)_continueReading
{
	[m_socket readDataToLength:8 withTimeout:-1 tag:kReadDataLengthTag];
}



#pragma mark -
#pragma mark AsyncSocket Delegate methods

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (tag == kReadDataLengthTag)
	{
		uint32_t pos = 0;
		const uint8_t *bytes = [data bytes];
		uint8_t ch1 = bytes[pos++];
		uint8_t ch2 = bytes[pos++];
		uint8_t ch3 = bytes[pos++];
		uint8_t ch4 = bytes[pos++];
		uint32_t len = CFSwapInt32BigToHost(((ch1 << 24) & 0xff000000) + ((ch2 << 16) & 0xff0000) + 
			((ch3 << 8) & 0xff00) + (ch4 & 0xff));
		
		ch1 = bytes[pos++];
		ch2 = bytes[pos++];
		ch3 = bytes[pos++];
		ch4 = bytes[pos++];
		uint32_t cmd = CFSwapInt32BigToHost(((ch1 << 24) & 0xff000000) + ((ch2 << 16) & 0xff0000) + 
			((ch3 << 8) & 0xff00) + (ch4 & 0xff));
		
		NSLog(@"cmd: %d, len: %d", cmd, len);
		
		if (len > 0)
		{
			[sock readDataToLength:len withTimeout:-1 tag:kReadDataTag];
			return;
		}
	}
	else if (tag == kReadDataTag)
	{
		NSLog(@"data: %@", [NSString stringWithUTF8String:[data bytes]]);
	}
	[self _continueReading];
}

@end