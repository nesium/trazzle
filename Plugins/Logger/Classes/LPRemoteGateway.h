//
//  LPRemoteGateway.h
//  Logger
//
//  Created by Marc Bauer on 16.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDuplexGateway.h"


@interface LPRemoteGateway : AMFRemoteGateway
{
	NSDictionary *m_connectionParams;
	NSMenuItem *m_menuItem;
	NSMutableArray *m_loggedImages;
}
@property (nonatomic, retain) NSDictionary *connectionParams;
@property (nonatomic, retain) NSMenuItem *menuItem;
@property (nonatomic, readonly) NSArray *loggedImages;

- (void)addLoggedImagePath:(NSString *)aPath;
@end
