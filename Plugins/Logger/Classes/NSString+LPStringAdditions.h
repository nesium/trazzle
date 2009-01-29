//
//  NSString+LPStringAdditions.h
//  Logger
//
//  Created by Marc Bauer on 29.01.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (LPStringAdditions)
- (NSString *)htmlEncodedString;
- (NSString *)htmlEncodedStringWithConvertedLinebreaks;
@end