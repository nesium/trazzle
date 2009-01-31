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
#import "MessageModel.h"
#import "LoggingViewController.h"
#import "AbstractMessage.h"

@interface LoggerPlugin : NSObject <TrazzlePlugIn> 
{
	PlugInController *controller;

	MessageModel *m_messageModel;
	LoggingViewController *m_loggingViewController;
}

- (id)initWithPlugInController:(PlugInController *)controller;

@end