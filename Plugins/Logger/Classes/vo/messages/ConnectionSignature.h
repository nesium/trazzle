//
//  ConnectionSignature.h
//  Trazzle
//
//  Created by Marc Bauer on 09.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConnectionSignature : NSObject 
{
	NSNumber *m_startTime;
	NSString *m_language;
}

@property (nonatomic, retain) NSNumber *startTime;
@property (nonatomic, retain) NSString *language;

@end