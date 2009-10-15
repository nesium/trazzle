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
#import "LPMessageModel.h"
#import "LoggingViewController.h"
#import "AbstractMessage.h"
#import "CommandMessage.h"
#import "LPFilterController.h"
#import "AMFDuplexGateway.h"
#import "LoggingService.h"
#import "MenuService.h"
#import "ExceptionMessage.h"
#import "LPSession.h"
#import "MessageParser.h"
#import "LPPreferencesViewController.h"
#import "FileObservingService.h"
#import "FileMonitor.h"

@interface LoggerPlugin : NSObject <TrazzlePlugIn, FileObserver>
{
	PlugInController *m_controller;
	
	NSMutableArray *m_sessions;
	
	NSTask *m_tailTask;
	NSPipe *m_logPipe;

	LPFilterController *m_filterController;
}
@end