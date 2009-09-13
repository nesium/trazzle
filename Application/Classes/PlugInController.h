//
//  PlugInController.h
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDuplexGateway.h"
#import "AsyncSocket.h"

@class ZZWindowController;
@protocol TrazzleTabViewDelegate;

@interface PlugInController : NSObject
{
	AMFDuplexGateway *m_sharedGateway;
	AsyncSocket *m_sharedLegacyConnection;
	NSArray *m_connectedClients;
}
@property (nonatomic, readonly) AMFDuplexGateway *sharedGateway;
@property (nonatomic, readonly) AsyncSocket *sharedLegacyConnection;
@property (nonatomic, readonly) NSArray *connectedClients;

- (id)initWithPlugInBundle:(NSBundle *)bundle windowController:(ZZWindowController *)controller 
	gateway:(AMFDuplexGateway *)gateway legacyConnection:(AsyncSocket *)legacyConnection 
	connectedClients:(NSArray *)connectedClients;

- (void)bringWindowToTop;
- (void)setWindowIsFloating:(BOOL)bFlag;
- (id)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate;
- (void)addStatusMenuItem:(NSMenuItem *)item;
- (void)removeStatusMenuItem:(NSMenuItem *)item;

@end