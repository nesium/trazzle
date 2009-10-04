//
//  SWDateAdditions.h
//  Subway
//
//  Created by Marc Bauer on 04.01.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDate (AAAdditions)
- (NSString *)relativeDateStringFromDate:(NSDate *)date 
	oldDateFormat:(NSString *)oldDateFormat;
@end