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
	
	MessageModel *m_messageModel;
	LoggingViewController *m_loggingViewController;
	LPFilterModel *m_filterModel;
	
	NSString *m_tabTitle;
	NSString *m_sessionName;
	BOOL m_isReady;
}
@property (nonatomic, retain) NSString *tabTitle;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, readonly) LPFilterModel *filterModel;
- (id)initWithPlugInController:(PlugInController *)controller;
- (void)handleFlashlogMessage:(AbstractMessage *)msg;
- (void)addRemoteGateway:(LPRemoteGateway *)gateway;
- (void)addLoggingClient:(LoggingClient *)client;
@end