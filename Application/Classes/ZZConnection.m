//
//  ZZConnection.m
//  Trazzle
//
//  Created by Marc Bauer on 12.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZConnection.h"

@interface ZZConnection (Private)
- (NSURL *)_normalizeSWFURL:(NSURL *)url;
@end


@implementation ZZConnection

@synthesize isLegacyConnection=m_isLegacyConnection, 
			remote=m_remote, 
			swfURL=m_swfURL;

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
		m_swfURL = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_remote release];
	[m_pluginStorage release];
	[m_connectionParams release];
	[m_swfURL release];
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
	
	[m_swfURL release];
	m_swfURL = [[self _normalizeSWFURL:[NSURL URLWithString:
		[m_connectionParams objectForKey:@"swfURL"]]] retain];
	
	if ([m_delegate respondsToSelector:@selector(connectionDidReceiveConnectionSignature:)])
		[m_delegate connectionDidReceiveConnectionSignature:self];
}

- (NSString *)applicationName
{
	return [m_connectionParams objectForKey:@"applicationName"];
}

- (void)disconnect
{
	if ([m_remote isMemberOfClass:[AsyncSocket class]])
		[(AsyncSocket *)m_remote disconnectAfterReadingAndWriting];
	else 
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

- (NSURL *)_normalizeSWFURL:(NSURL *)url
{
	// this is out of our range
	if (![url isFileURL])
		return url;
	
	// non absolute path are not valid either
	if (![[url path] isAbsolutePath])
		return url;
	
	// if the path is valid everything is fine
	BOOL isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDir] && !isDir)
		return url;
	
	// in order to get to a useful result with what we're up to, the path should at least 
	// have one component in addition to the filename (the first component is the / in an absolute path)
	NSArray *pathComponents = [[url path] pathComponents];
	if ([pathComponents count] < 3)
		return url;
	
	// here we go
	// the flash ide has the annoying habit to add the volume name ahead of the path, eg.
	// file:///One/Daten/Projekte/Polymer/Lightlineplaner/project/bin/Lightlineplaner.swf
	// this is by all standards known to me plain wrong. the other problem is, that it doesn't 
	// compare very well to well-formed paths, so we try to remove the volume name if there is any ...
	FSVolumeRefNum actualVolume;
	FSVolumeInfo info;
	HFSUniStr255 volumeName;
	uint32_t index = 1;
	while (FSGetVolumeInfo(kFSInvalidVolumeRefNum, index++, &actualVolume, kFSVolInfoFSInfo, &info, 
		&volumeName, NULL) != nsvErr)
	{
		NSString *volName = [NSString stringWithCharacters:volumeName.unicode 
			length:volumeName.length];
		if ([volName isEqualToString:[pathComponents objectAtIndex:1]])
		{
			NSString *validPath = [NSString stringWithFormat:@"file:///%@", 
				[NSString pathWithComponents:[pathComponents subarrayWithRange:
					(NSRange){2, [pathComponents count] - 2}]]];
			return [NSURL URLWithString:validPath];
		}
	}
	
	return url;
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