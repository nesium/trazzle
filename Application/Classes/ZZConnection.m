//
//  ZZConnection.m
//  Trazzle
//
//  Created by Marc Bauer on 12.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZConnection.h"


@implementation ZZConnection

@synthesize isLegacyConnection=m_isLegacyConnection, 
			remote=m_remote;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithRemote:(id)remote delegate:(id)delegate
{
	if (self = [super init])
	{
		m_remote = [remote retain];
		m_delegate = delegate;
		m_isLegacyConnection = [remote isMemberOfClass:[AsyncSocket class]];
		if (m_isLegacyConnection)
			[(AsyncSocket *)remote setDelegate:self];
		m_pluginStorage = [[NSMutableDictionary alloc] init];
		m_connectionParams = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_remote release];
	[m_pluginStorage release];
	[m_connectionParams release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSMutableDictionary *)storageForPluginWithName:(NSString *)name
{
	if ([m_pluginStorage objectForKey:name] == nil)
		[m_pluginStorage setObject:[NSMutableDictionary dictionary] forKey:name];
	return [m_pluginStorage objectForKey:name];
}

- (void)setConnectionParams:(NSDictionary *)params
{
	[params retain];
	[m_connectionParams release];
	m_connectionParams = params;
	if ([m_delegate respondsToSelector:@selector(connectionDidReceiveConnectionSignature:)])
		[m_delegate connectionDidReceiveConnectionSignature:self];
}

- (NSString *)applicationName
{
	return [m_connectionParams objectForKey:@"applicationName"];
}

- (NSString *)swfURL
{
	return [m_connectionParams objectForKey:@"swfURL"];
}

- (void)disconnect
{
	[m_remote disconnect];
}



#pragma mark -
#pragma mark Private methods

- (void)_continueReading
{
	[(AsyncSocket *)m_remote readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];	
}

- (void)_sendString:(NSString *)msg
{
	NSData *data = [[msg stringByAppendingString:@"\0"] dataUsingEncoding:NSUTF8StringEncoding];
	[(AsyncSocket *)m_remote writeData:data withTimeout:-1 tag:0];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"didConnectToHost");
	[self _continueReading];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *message = [NSString stringWithUTF8String:[data bytes]];
	if ([message isEqualToString:@"<policy-file-request/>"])
	{
		[self _sendString:@"<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/>\
</cross-domain-policy>\0"];
		return;
	}
	
	if ([m_delegate respondsToSelector:@selector(connection:didReceiveMessage:)])
		[m_delegate connection:self didReceiveMessage:message];
	
	[self _continueReading];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if ([m_delegate respondsToSelector:@selector(connectionDidDisconnect:)])
		[m_delegate connectionDidDisconnect:self];
}



//#pragma mark -
//#pragma mark FileMonitor Delegate methods
//
//- (void)fileMonitor:(FileMonitor *)fm fileDidChangeAtPath:(NSString *)path
//{
//	[self performSelectorOnMainThread:@selector(_sendString:) 
//		withObject:[NSString stringWithFormat:@"<event type=\"fileChange\" path=\"%@\"/>", path] 
//		waitUntilDone:NO];
//}

@end