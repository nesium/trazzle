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
}
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
	BOOL selected;
	SWFMenu *submenu;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) SWFMenu *submenu;
@property (nonatomic, assign) BOOL selected;
@end


@interface NSObject (MenuServiceDelegate)
- (void)menuService:(MenuService *)service didReceiveMenu:(NSMenu *)menu 
		fromGateway:(AMFRemoteGateway *)gateway;
@end