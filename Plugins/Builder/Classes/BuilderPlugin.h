//
//  BuilderPlugin.h
//  Builder
//
//  Created by Marc Bauer on 16.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrazzlePlugIn.h"
#import "BLDCompilerSettingsWindowController.h"


@interface BuilderPlugin : NSObject <TrazzlePlugIn, TrazzleTabViewDelegate>
{
	PlugInController *controller;
	BLDCompilerSettingsWindowController *m_compilerSettingsController;
	
	NSTask *m_fcshTask;
	NSPipe *m_fcshInPipe;
	NSPipe *m_fcshOutPipe;
	NSTextView *m_compilerOutputText;
	NSTextField *m_commandInputText;
	NSView *m_compilerOutputView;
	NSMutableArray *m_commandHistory;
	NSUInteger m_historyIndex;
}
- (id)initWithPlugInController:(PlugInController *)controller;
- (IBAction)sendCommand:(id)sender;
@end