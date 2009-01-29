//
//  PluginController.h
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageController.h"
#import "AbstractPlugin.h"

typedef enum _WindowBehaviourMode
{
	WBMBringToTop,
	WBMKeepOnTopWhileConnected,
	WBMKeepAlwaysOnTop,
	WBMDoNothing
} WindowBehaviourMode;

@interface LoggerPlugin : AbstractPlugin 
{
	MessageController *m_messageController;
}

@end