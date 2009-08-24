//
//  LPSession.h
//  Logger
//
//  Created by Marc Bauer on 21.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrazzlePlugIn.h"
#import "MessageModel.h"
#import "LoggingViewController.h"
#import "AMFDuplexGateway.h"
#import "LoggingService.h"
#import "FileMonitor.h"
#import "LoggingClient.h"
#import "MenuService.h"
#import "LPFilterModel.h"


@interface LPSession : NSObject <TrazzleTabViewDelegate>
{
	PlugInController *m_controller;
	id m_tab;
	id m_representedObject;
	id m_delegate;
	
	MessageModel *m_messageModel;
	LoggingViewController *m_loggingViewController;
	LPFilterModel *m_filterModel;
	
	NSString *m_tabTitle;
	NSString *m_sessionName;
	NSString *m_swfURL;
	BOOL m_isReady;
	BOOL m_isDisconnected;
	BOOL m_isActive;
	
	NSImage *m_icon;
}
@property (nonatomic, retain) NSString *tabTitle;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSString *swfURL;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isDisconnected;
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, readonly) LPFilterModel *filterModel;
@property (nonatomic, assign) id representedObject;
@property (nonatomic, assign) id delegate;
- (id)initWithPlugInController:(PlugInController *)controller;
- (void)handleFlashlogMessage:(AbstractMessage *)msg;
- (void)addRemoteGateway:(LPRemoteGateway *)gateway;
- (void)addLoggingClient:(LoggingClient *)client;
@end

@interface NSObject (LPSessionDelegate)
- (void)session:(LPSession *)session loggingClientDidDisconnect:(LoggingClient *)client;
@end