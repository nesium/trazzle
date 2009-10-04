//
//  ZZUpdatePreferencesViewController.m
//  Trazzle
//
//  Created by Marc Bauer on 01.10.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZUpdatePreferencesViewController.h"

@interface ZZUpdatePreferencesViewController (Private)
- (void)_updateLastUpdateCheckDate;
@end


@implementation ZZUpdatePreferencesViewController

- (void)prefPaneWillMoveToWindow
{
	if ([[self view] window] != nil)
		return;

	[m_installUpdateButton setHidden:YES];
	[m_updateInfoText setStringValue:@""];
	[self _updateLastUpdateCheckDate];
	
	// In the application bundle SUFeedURL is by default set to the major releases feed
	// so, obviously if SUFeedURL in the UserDefaultController is not equal to the url 
	// specified in the bundle, it is set to beta
	[m_updateTypePopUpButton selectItemWithTag:([[[[NSUserDefaultsController 
		sharedUserDefaultsController] values] valueForKey:@"SUFeedURL"] 
		isEqualToString:[[[NSBundle mainBundle] infoDictionary] 
		objectForKey:@"SUFeedURL"]] ? 0 : 1)];
	
	// update frequency popupbutton
	BOOL checkForUpdatesOnStartup = [[[[NSUserDefaultsController sharedUserDefaultsController]
		values] valueForKey:@"ZZCheckForUpdatesOnStartup"] boolValue];
	if (checkForUpdatesOnStartup)
		[m_updateFrequencyPopUpButton selectItemWithTag:0];
	else if (![m_updater automaticallyChecksForUpdates])
		[m_updateFrequencyPopUpButton selectItemWithTag:-1];
	else
		[m_updateFrequencyPopUpButton selectItemWithTag:[m_updater updateCheckInterval]];
}



#pragma mark -
#pragma mark Overridden NSViewController methods

- (NSString *)title
{
	return @"Updates";
}



#pragma mark -
#pragma mark IB methods

- (IBAction)checkForUpdates:(id)sender
{
	[[SUUpdater sharedUpdater] setDelegate:self];
	[[SUUpdater sharedUpdater] checkForUpdateInformation];
}

- (IBAction)updateTypePopUpButton_change:(id)sender
{
	BOOL includeBetaReleases = [(NSPopUpButton *)sender selectedTag] == 1;
	NSString *feedURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SUFeedURL"];
	if (includeBetaReleases)
		feedURL = [NSString stringWithFormat:@"%@/Beta", feedURL];
	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:feedURL forKey:@"SUFeedURL"];
}

- (IBAction)updateFrequencyPopUpButton_change:(id)sender
{
	NSInteger tag = [(NSPopUpButton *)sender selectedTag];
	BOOL checkForUpdatesOnStartup = NO;
	if (tag == -1)
		[m_updater setAutomaticallyChecksForUpdates:NO];
	else if (tag == 0)
	{
		[m_updater setAutomaticallyChecksForUpdates:NO];
		checkForUpdatesOnStartup = YES;
	}
	else
		[m_updater setUpdateCheckInterval:tag];

	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:[NSNumber numberWithBool:checkForUpdatesOnStartup] 
			forKey:@"ZZCheckForUpdatesOnStartup"];
}



#pragma mark -
#pragma mark Private methods

- (void)_updateLastUpdateCheckDate
{
	NSDate *lastCheckDate = [[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey:@"SULastCheckTime"];
	if (lastCheckDate == nil)
	{
		[m_updateDateText setStringValue:NSLocalizedString(@"Never", @"")];
		return;
	}	
	[m_updateDateText setStringValue:[lastCheckDate relativeDateStringFromDate:nil 
		oldDateFormat:nil]];
}




#pragma mark -
#pragma mark SUStatusChecker delegate methods

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:[NSDate date] forKey:@"SULastCheckTime"];
	[self _updateLastUpdateCheckDate];
	NSString *infoString = [NSString stringWithFormat:@"Newest version is %@. You have version %@ installed.", 
			[update displayVersionString], [[[NSBundle mainBundle] infoDictionary] 
				objectForKey:@"CFBundleShortVersionString"]];
	[m_installUpdateButton setHidden:NO];
	[m_updateInfoText setStringValue:infoString];
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
	[[[NSUserDefaultsController sharedUserDefaultsController] values] 
		setValue:[NSDate date] forKey:@"SULastCheckTime"];
	[self _updateLastUpdateCheckDate];
	[m_updateInfoText setStringValue:@"You're up to date!"];
	[m_installUpdateButton setHidden:YES];
}

@end