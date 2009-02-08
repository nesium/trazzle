//
//  NSMMenuController.h
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMMenuController : NSObject
{
	uint32_t m_insertionIndex;
	NSMutableArray *m_menuItems;
	NSArray *m_content;
	NSArrayController *m_arrayController;
	NSMenu *m_menu;
	NSString *m_titleKey;
	SEL m_defaultAction;
	id m_defaultTarget;
}
@property (nonatomic, assign) uint32_t insertionIndex;
@property (nonatomic, retain) NSString *titleKey;
@property (nonatomic, assign) SEL defaultAction;
@property (nonatomic, retain) id defaultTarget;

- (id)initWithMenu:(NSMenu *)menu;

@end