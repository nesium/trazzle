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
}
- (id)initWithPlugInController:(PlugInController *)controller;
@end