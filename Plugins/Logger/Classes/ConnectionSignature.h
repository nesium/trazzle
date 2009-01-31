//
//  ConnectionSignature.h
//  Trazzle
//
//  Created by Marc Bauer on 09.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractMessage.h"


@interface ConnectionSignature : AbstractMessage 
{
	NSNumber *startTime;
	NSString *language;
}

@property (nonatomic, retain) NSNumber *startTime;
@property (nonatomic, retain) NSString *language;

@end