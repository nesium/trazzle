//
//  SystemMessage.h
//  Trazzle
//
//  Created by Marc Bauer on 13.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SystemMessage : NSObject 
{
	NSString *m_message;
}

@property (retain, nonatomic) NSString *message;

@end