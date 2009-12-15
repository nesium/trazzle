//
//  NSFileManager+LPAdditions.m
//  Logger
//
//  Created by Marc Bauer on 15.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSFileManager+LPAdditions.h"


@implementation NSFileManager (LPAdditions)

- (NSString *)nextAvailableFilenameAtPath:(NSString *)aPath proposedFilename:(NSString *)aName{
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:[aPath stringByAppendingPathComponent:aName]])
		return aName;
	unsigned int i = 1;
	NSString *extension = [aName pathExtension];
	NSString *filenameNoSuffix = [aName stringByDeletingPathExtension];
	for (;;){
		NSString *filename = [[NSString stringWithFormat:@"%@-%d", filenameNoSuffix, i++] 
			stringByAppendingPathExtension:extension];
		if (![fm fileExistsAtPath:[aPath stringByAppendingPathComponent:filename]])
			return filename;
	}
	return nil;
}
@end