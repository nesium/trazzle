//
//  PlugInController.h
//  Trazzle
//
//  Created by Marc Bauer on 14.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>
#import "ZZConnection.h"

@class ZZWindowController;
@protocol TrazzleTabViewDelegate;

@interface ZZPlugInController : NSObject{
@private
	AMFDuplexGateway *m_sharedGateway;
	AsyncSocket *m_sharedLegacyConnection;
	NSArray *m_connectedClients;
	ZZWindowController *m_windowController;
	NSStatusItem *m_statusItem;
	NSBundle *m_plugInBundle;
	NSDictionary *m_registeredPlugIns;
}
@property (nonatomic, readonly) AMFDuplexGateway *sharedGateway;
@property (nonatomic, readonly) AsyncSocket *sharedLegacyConnection;
@property (nonatomic, readonly) NSArray *connectedClients;
@property (nonatomic, readonly) NSDictionary *registeredPlugIns;

- (id)initWithPlugInBundle:(NSBundle *)bundle windowController:(ZZWindowController *)controller 
	gateway:(AMFDuplexGateway *)gateway legacyConnection:(AsyncSocket *)legacyConnection 
	connectedClients:(NSArray *)connectedClients;
- (void)bringWindowToTop;
- (void)setWindowIsFloating:(BOOL)bFlag;
- (id)addTabWithIdentifier:(id)ident view:(NSView *)view 
	delegate:(id <TrazzleTabViewDelegate>)delegate;
- (void)selectTabItemWithDelegate:(id<TrazzleTabViewDelegate>)aDelegate;
- (id)selectedTabDelegate;
- (void)addStatusMenuItem:(NSMenuItem *)item;
- (void)removeStatusMenuItem:(NSMenuItem *)item;
- (ZZConnection *)connectionForRemote:(id)remote;
@end