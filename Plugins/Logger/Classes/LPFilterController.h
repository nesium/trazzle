//
//  LPFilterController.h
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "ZZConstants.h"
#import "LPFilter.h"
#import "NSMMenuController.h"


@interface LPFilterController : NSWindowController
{
	IBOutlet NSMenu *m_mainMenu;
	IBOutlet NSArrayController *m_filterArrayController;
	IBOutlet NSArrayController *m_filterMenuArrayController;
	id m_delegate;
	LPFilter *m_activeFilter;
	NSMutableArray *m_filters;
	NSMMenuController *m_mainMenuController;
	BOOL m_filteringIsEnabled;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) LPFilter *activeFilter;
@property (nonatomic, assign) BOOL filteringIsEnabled;
- (IBAction)editFilters:(id)sender;
- (IBAction)toggleFilteringIsEnabled:(id)sender;
@end


@interface NSObject (LPFilterControllerDelegate)
- (void)filterController:(LPFilterController *)controller didSelectFilter:(LPFilter *)filter;
- (void)filterController:(LPFilterController *)controller 
	didChangeFilteringEnabledFlag:(BOOL)isEnabled;
@end