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
	
	NSMutableArray *m_filters;
	NSMMenuController *m_mainMenuController;
}
- (IBAction)editFilters:(id)sender;
@end