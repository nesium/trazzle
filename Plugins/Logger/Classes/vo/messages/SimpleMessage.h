//
//  SimpleMessage.h
//  Logger
//
//  Created by Marc Bauer on 22.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleMessage : NSObject 
{
	NSString *m_message;
	NSTimeInterval m_timestamp;
}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end