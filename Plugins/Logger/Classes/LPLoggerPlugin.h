//
//  PluginController.h
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>
#import "ZZTrazzlePlugIn.h"
#import "LPConstants.h"
#import "LPMessageModel.h"
#import "LoggingViewController.h"
#import "AbstractMessage.h"
#import "CommandMessage.h"
#import "LPFilterWindowController.h"
#import "LoggingService.h"
#import "MenuService.h"
#import "ExceptionMessage.h"
#import "LPSession.h"
#import "MessageParser.h"
#import "LPPreferencesViewController.h"
#import "FileObservingService.h"
#import "FileMonitor.h"
#import "LPMMCfgFile.h"
#import "LPTailTask.h"

@interface LPLoggerPlugin : NSObject <ZZTrazzlePlugIn, FileObserver>{
	ZZPlugInController *m_controller;
	NSMutableArray *m_sessions;
	LPTailTask *m_tailTask;
	BOOL m_autoSelectTab;
	LPFilterWindowController *m_filterController;
	NSObject *m_inspectorPlugin;
}
@end