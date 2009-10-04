//
//  ZZUpdatePreferencesViewController.h
//  Trazzle
//
//  Created by Marc Bauer on 01.10.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/SUUpdater.h>
#import <Sparkle/SUAppcastItem.h>
#import "NSDate+AAAdditions.h"


@interface ZZUpdatePreferencesViewController : NSViewController 
{
	IBOutlet SUUpdater *m_updater;
	IBOutlet NSTextField *m_updateInfoText;
	IBOutlet NSTextField *m_updateDateText;
	IBOutlet NSButton *m_installUpdateButton;
	IBOutlet NSPopUpButton *m_updateTypePopUpButton;
	IBOutlet NSPopUpButton *m_updateFrequencyPopUpButton;
}
- (IBAction)checkForUpdates:(id)sender;
- (IBAction)updateTypePopUpButton_change:(id)sender;
- (IBAction)updateFrequencyPopUpButton_change:(id)sender;
- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update;
- (void)updaterDidNotFindUpdate:(SUUpdater *)update;
@end