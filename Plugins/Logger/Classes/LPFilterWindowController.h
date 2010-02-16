//
//  LPFilterController.h
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LPConstants.h"
#import "ZZConstants.h"
#import "LPFilter.h"
#import "NSMMenuController.h"
#import "SelectedFilterToIconTransformer.h"
#import "LPFilterModel.h"


@interface LPFilterWindowController : NSWindowController{
	IBOutlet NSMenu *m_mainMenu;
	IBOutlet NSArrayController *m_filterArrayController;
	IBOutlet NSArrayController *m_filterMenuArrayController;
	IBOutlet NSTableView *m_filtersTable;
	IBOutlet NSMenuItem *m_filteringIsEnabledMenuItem;
	NSMMenuController *m_mainMenuController;
	LPFilterModel *m_model;
}
@property (nonatomic, assign) LPFilterModel *model;
- (IBAction)editFilters:(id)sender;
- (IBAction)toggleFilteringIsEnabled:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)duplicate:(id)sender;
- (IBAction)remove:(id)sender;
@end