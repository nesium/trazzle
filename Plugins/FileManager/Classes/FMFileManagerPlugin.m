//
//  FMFileManagerPlugin.m
//  FileManager
//
//  Created by Marc Bauer on 05.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "FMFileManagerPlugin.h"

@interface FMFileManagerPlugin (Private)
- (void)_sendConstantsToRemote:(AMFRemoteGateway *)remote;
@end


@implementation FMFileManagerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(ZZPlugInController *)aController{
	if (self = [super init]){
		m_controller = aController;
		[aController.sharedGateway registerService:[[[FMFileService alloc] init] autorelease] 
			withName:@"FileService"];
	}
	return self;
}

- (void)trazzleDidOpenConnection:(ZZConnection *)conn{
}

- (void)trazzleDidCloseConnection:(ZZConnection *)conn{
}

- (void)trazzleDidReceiveSignatureForConnection:(ZZConnection *)conn{
	if (conn.isLegacyConnection)
		return;
	[self _sendConstantsToRemote:(AMFRemoteGateway *)conn.remote];
}


#pragma mark -
#pragma mark Private methods

- (void)_sendConstantsToRemote:(AMFRemoteGateway *)remote{
	NSMutableDictionary *constants = [NSMutableDictionary dictionary];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, 
			NSUserDomainMask, YES);
	[constants setObject:[paths objectAtIndex:0] forKey:@"Desktop"];
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[constants setObject:[paths objectAtIndex:0] forKey:@"Documents"];
	[constants setObject:NSHomeDirectory() forKey:@"User"];
	[remote invokeRemoteService:@"FileService" methodName:@"setConstants" arguments:constants, nil];
}
@end