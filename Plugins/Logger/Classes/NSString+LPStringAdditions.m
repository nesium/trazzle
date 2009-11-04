//
//  NSString+LPStringAdditions.m
//  Logger
//
//  Created by Marc Bauer on 29.01.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import "NSString+LPStringAdditions.h"


@implementation NSString (LPStringAdditions)

- (NSString *)htmlEncodedString
{
	NSString *escapedString = (NSString *)CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault,
		(CFStringRef)self, NULL);
	return [escapedString autorelease];
}

- (NSString *)htmlEncodedStringWithConvertedLinebreaks
{
	NSMutableString *escapedString = [NSMutableString stringWithString:[self htmlEncodedString]];
	[escapedString replaceOccurrencesOfString:@"\r\n" withString: @"\n" 
		options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
	[escapedString replaceOccurrencesOfString:@"\n" withString:@"<br />" 
		options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
	[escapedString replaceOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;" 
		options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
	NSLog(@"%@", escapedString);
	return escapedString;
}

@end