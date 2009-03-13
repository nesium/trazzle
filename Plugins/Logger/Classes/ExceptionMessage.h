//
//  ExceptionMessage.h
//  Logger
//
//  Created by Marc Bauer on 13.03.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogMessage.h"


@interface ExceptionMessage : LogMessage 
{
	NSString *errorType;
	uint32_t errorNumber;
}
@property (nonatomic, retain) NSString *errorType;
@property (nonatomic, assign) uint32_t errorNumber;
@end