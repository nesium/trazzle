//
//  NSNumber+FileSize.m
//  PerformanceMonitor
//
//  Created by Marc Bauer on 13.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSNumber+FileSize.h"


@implementation NSNumber (FileSize)

- (NSString *)fileSizeString
{
	static uint64_t count = 7;
	static NSString *suffixes[7] = {@"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB"};
	uint64_t i, c;
	uint64_t bytes = [self intValue];
	
	for (i = 1024, c = 0; i < (count << 60); i <<= 10, c++)
	{
	    if (bytes < i) 
	        return [NSString stringWithFormat:@"%0.2f %@", (double)bytes / (double)(i >> 10), 
				suffixes[c]];
	}
	return @"Big";
}

@end