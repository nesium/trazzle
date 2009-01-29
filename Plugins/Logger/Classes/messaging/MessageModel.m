//
//  MessageModel.m
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "MessageModel.h"

@interface MessageModel (Private)
- (void)openSocket;
- (void)closeSocket;
- (void)tailFlashlog;
@end

#define kLoggerReadMessageTag 1


@implementation MessageModel

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		m_connectedClients = [[NSMutableArray alloc] init];
		[self openSocket];
		[self tailFlashlog];
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[m_connectedClients release];
	[super dealloc];
}



#pragma mark -
#pragma mark Private methods

- (void)openSocket
{
	int port = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		valueForKey:@"LPServerPort"] intValue];

	if (port < 0 || port > 65535)
	{
		port = 0;
	}
	
	NSError *error = nil;
	if (![m_socket acceptOnPort:port error:&error])
	{
		NSLog(@"Could not start server on port %d. Reason: %@", port, error);
		return;
	}
	NSLog(@"started server on port %d", [m_socket localPort]);
}

- (void)closeSocket
{
	if (![m_socket isConnected])
	{
		return;
	}
	[m_socket disconnect];
	for (AsyncSocket *client in m_connectedClients)
	{
		[client disconnect];
	}
}

- (void)tailFlashlog
{
	m_tailTask = [[NSTask alloc] init];
	m_logPipe = [[NSPipe alloc] init];
	[m_tailTask setLaunchPath:@"/usr/bin/tail"];
	[m_tailTask setArguments:[NSArray arrayWithObjects:@"-F", 
		[@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
			stringByExpandingTildeInPath], nil]];
	[m_tailTask setStandardOutput:m_logPipe];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) 
		name:NSFileHandleReadCompletionNotification object:[m_logPipe fileHandleForReading]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) 
		name:NSTaskDidTerminateNotification object:m_tailTask];
		
	[m_tailTask launch];
	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	NSLog(@"did accept new socket");
	[m_connectedClients addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"socket did connect to host %@", host);
	[sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:kLoggerReadMessageTag];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *message = [NSString stringWithUTF8String:[data bytes]];
	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message];
	NSLog(@"data: %@", [parser data]);
	[parser release];
	[sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:kLoggerReadMessageTag];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"socket did write data");
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"socket will disconnect with error");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"socket did disconnect");
	[m_connectedClients removeObject:sock];
}



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification
{
	NSLog(@"task terminated");
}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSLog(@"read data: %@", [NSString stringWithUTF8String:[data bytes]]);
	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
}

@end