//
//  SWAbstractToolbarWindowController.h
//  Subway
//
//  Created by Marc Bauer on 27.12.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Manages a preferences window, handling the toolbar and shows and hides the according views.
// The toolbar is created upon the first showWindow: message, thus there is enough time to 
// set it up via the addPrefPane ... methods
@interface AAPreferencesWindowController : NSWindowController 
{
	NSMutableArray *m_toolbarItems;
	NSViewController *m_activeController;
	NSString *m_toolbarIdentifier;
	BOOL m_toolbarAllowsUserCustomization;
	BOOL m_toolbarAutosavesConfiguration;
	NSToolbarSizeMode m_toolbarSizeMode;
	NSToolbarDisplayMode m_toolbarDisplayMode;
	NSString *m_windowAutosaveName;
}
// The identifier is used as the autosave name for toolbars that save their configuration, 
// Defaults to MainToolbar. Must be set before the toolbar is created!
@property (nonatomic, retain) NSString *toolbarIdentifier;
// Defaults to NO
@property (nonatomic, assign) BOOL toolbarAllowsUserCustomization;
// When autosaving is enabled, the receiver will automatically write the toolbar settings to user 
// Defaults if the toolbar configuration changes. defaults to YES
@property (nonatomic, assign) BOOL toolbarAutosavesConfiguration;
// Defaults to NSToolbarSizeModeDefault
@property (nonatomic, assign) NSToolbarSizeMode toolbarSizeMode;
// Defaults to NSToolbarDisplayModeDefault
@property (nonatomic, assign) NSToolbarDisplayMode toolbarDisplayMode;
// Used in UserPreferences, defaults to PreferencesWindowOrigin
@property (nonatomic, retain) NSString *windowAutosaveName;

// Adds a view and the respecting ToolbarItem, uses the ViewControllers title property for display 
// and identifying purposes
- (void)addPrefPaneWithController:(NSViewController *)controller icon:(NSImage *)icon;
@end


@interface NSObject (AAPreferencesViewController)
- (void)prefPaneWillMoveToWindow;
- (void)prefPaneDidMoveToWindow;
@end