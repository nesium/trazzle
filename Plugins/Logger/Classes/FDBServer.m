//
//  FDBServer.m
//  Logger
//
//  Created by Marc Bauer on 14.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FDBServer.h"

#define kDEBUG_PORT 7935

@implementation FDBServer

- (id)init
{
	if (self = [super init])
	{
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		[m_socket acceptOnPort:kDEBUG_PORT error:nil];
	}
	return self;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	NSLog(@"client connected");
	[newSocket retain];
	[newSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//[data writeToFile:@"/Users/mb/Desktop/test.bin" atomically:NO];
	NSLog(@"test: %@", [AMF3Unarchiver unarchiveObjectWithData:data encoding:kAMF3Version]);
}

@end