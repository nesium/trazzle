//
//  DocumentController.h
//  Trazzle
//
//  Created by Marc Bauer on 25.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/objc-runtime.h>
#import "AMFDuplexGateway.h"
#import "AsyncSocket.h"
#import "ZZWindowController.h"
#import "PlugInController.h"
#import "TrazzlePlugIn.h"
#import "ZZConnection.h"
#import "ZZCoreService.h"

#define SUPPORT_PATH @"~/Library/Application Support/Trazzle"

@interface ZZController : NSObject
{
	NSMutableArray *m_connectedClients;
	AsyncSocket *m_socket;
	AMFDuplexGateway *m_gateway;
	NSMutableArray *m_loadedPlugins;
	NSMutableArray *m_plugInControllers;
	ZZWindowController *m_windowController;
}
@end