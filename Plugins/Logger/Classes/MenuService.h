//
//  MenuService.h
//  Logger
//
//  Created by Marc Bauer on 16.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDuplexGateway.h"


@interface MenuService : NSObject
{
	id m_delegate;
}
@property (nonatomic, assign) id delegate;
- (id)initWithDelegate:(id)delegate;
@end


@interface SWFMenu : NSObject
{
	NSArray *menuItems;
}
@property (nonatomic, retain) NSArray *menuItems;
@end

@interface SWFMenuItem : NSObject
{
	NSString *title;
	SWFMenu *submenu;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) SWFMenu *submenu;
@end


@interface NSObject (MenuServiceDelegate)
- (void)menuService:(MenuService *)service didReceiveMenu:(NSMenu *)menu 
		fromGateway:(AMFRemoteGateway *)gateway;
@end