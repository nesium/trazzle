//
//  LPSession.h
//  Logger
//
//  Created by Marc Bauer on 21.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrazzlePlugIn.h"
#import "LPMessageModel.h"
#import "LoggingViewController.h"
#import "AMFDuplexGateway.h"
#import "LoggingService.h"
#import "FileMonitor.h"
#import "MenuService.h"
#import "LPFilterModel.h"
#import "ZZConnection.h"
#import "NSPointerArray+LPAdditions.h"


@interface LPSession : NSObject <TrazzleTabViewDelegate>
{
	PlugInController *m_controller;
	id m_tab;
	NSPointerArray *m_representedObjects;
	id m_delegate;
	
	LPMessageModel *m_messageModel;
	LoggingViewController *m_loggingViewController;
	LPFilterModel *m_filterModel;
	
	NSString *m_tabTitle;
	NSString *m_sessionName;
	NSURL *m_swfURL;
	BOOL m_isReady;
	BOOL m_isDisconnected;
	BOOL m_isActive;
	BOOL m_isPristine;
	BOOL m_isMixed;
	
	NSImage *m_icon;
}
@property (nonatomic, retain) NSString *tabTitle;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSURL *swfURL;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isDisconnected;
@property (nonatomic, assign) BOOL isPristine;
@property (nonatomic, assign) BOOL isMixed;
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, readonly) LPFilterModel *filterModel;
@property (nonatomic, readonly) NSPointerArray *representedObjects;
@property (nonatomic, assign) id delegate;
- (id)initWithPlugInController:(PlugInController *)controller;
- (void)handleMessage:(AbstractMessage *)msg;
- (void)addConnection:(ZZConnection *)connection;
- (void)removeConnection:(ZZConnection *)connection;
- (BOOL)containsConnection:(ZZConnection *)connection;
@end