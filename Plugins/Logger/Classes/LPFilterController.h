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
	id m_delegate;
	LPFilter *m_activeFilter;
	NSMutableArray *m_filters;
	NSMMenuController *m_mainMenuController;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) LPFilter *activeFilter;
- (IBAction)editFilters:(id)sender;
@end


@interface NSObject (LPFilterControllerDelegate)
- (void)filterController:(LPFilterController *)controller didSelectFilter:(LPFilter *)filter;
@end