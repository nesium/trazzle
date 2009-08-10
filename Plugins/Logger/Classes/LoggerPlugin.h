//
//  PluginController.h
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrazzlePlugIn.h"
#import "Constants.h"
#import "AsyncSocket.h"
#import "LoggingClient.h"
#import "MessageModel.h"
#import "LoggingViewController.h"
#import "AbstractMessage.h"
#import "CommandMessage.h"
#import "LPFilterController.h"
#import "FileMonitor.h"
#import "AMFDuplexGateway.h"
#import "LoggingService.h"
#import "ExceptionMessage.h"

@interface LoggerPlugin : NSObject <TrazzlePlugIn, TrazzleTabViewDelegate> 
{
	PlugInController *controller;
	
	AsyncSocket *m_socket;
	AMFDuplexGateway *m_gateway;
	NSMutableArray *m_connectedClients;
	
	NSTask *m_tailTask;
	NSPipe *m_logPipe;
	NSString *m_flashlogBuffer;
	ExceptionMessage *m_currentException;
	NSMutableString *m_currentExceptionStacktrace;
	
	MessageModel *m_messageModel;
	LoggingViewController *m_loggingViewController;
	LPFilterController *m_filterController;
}

- (id)initWithPlugInController:(PlugInController *)controller;

@end