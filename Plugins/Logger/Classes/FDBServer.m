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
		m_preferences = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:120000], kFDBPrefAcceptTimeout, 
			[NSNumber numberWithInt:1], kFDBPrefURIModification, 
			[NSNumber numberWithInt:750], kFDBPrefResponseTimeout, 
			[NSNumber numberWithInt:1000], kFDBPrefContextResponseTimeout, 
			[NSNumber numberWithInt:1500], kFDBPrefGetVarResponseTimeout, 
			[NSNumber numberWithInt:5000], kFDBPrefSetVarResponseTimeout, 
			[NSNumber numberWithInt:5000], kFDBPrefSWFSWDLoadTimeout, 
			[NSNumber numberWithInt:7000], kFDBPrefSuspendWait, 
			[NSNumber numberWithInt:1], kFDBPrefInvokeGetters, 
			[NSNumber numberWithInt:0], kFDBPrefHierarchicalVariables, 
			nil];
		
		m_connections = [[NSMutableArray alloc] init];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		[m_socket acceptOnPort:kDEBUG_PORT error:nil];
	}
	return self;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	NSLog(@"client connected");
	[m_connections addObject:[FDBConnection connectionWithSocket:newSocket]];
}

@end