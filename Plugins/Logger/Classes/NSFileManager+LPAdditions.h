//
//  NSFileManager+LPAdditions.h
//  Logger
//
//  Created by Marc Bauer on 15.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (LPAdditions)
- (NSString *)nextAvailableFilenameAtPath:(NSString *)aPath proposedFilename:(NSString *)aName;
@end