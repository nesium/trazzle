//
//  StackTraceParser.m
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "StackTraceParser.h"


@implementation StackTraceParser

+ (NSArray *)parseStackTrace:(NSString *)stacktrace ofLanguageType:(NSString *)language
{
	if (language == nil)
	{
		language = @"as3";
	}
	return [StackTraceParser parseAS3StackTrace:stacktrace];
}

+ (NSArray *)parseAS3StackTrace:(NSString *)stacktrace
{
	NSMutableArray *stackItems = [NSMutableArray array];
	NSArray *lines = [stacktrace componentsSeparatedByString:@"\n"];
	for (int32_t i = 1; i < [lines count]; i++) // ignore first line
	{
//		NSString *line = [lines objectAtIndex:i];
		
//		NSRange firstBracketRange = [line rangeOfString:@"["];
		
//		StackTraceItem *item = [[StackTraceItem alloc] init];
//		[item setFQClassName:
//			[[className stringByReplacingOccurrencesOfString:@"::" withString:@"."]
//				stringByReplacingOccurrencesOfString:@":" withString:@"."]];
//		[item setMethod:method];
//		[item setFile:file];
//		[item setLine:[lineNo intValue]];
//		if (className == nil)
//		{
//			// no package found
//			[item setFQClassName:
//				[[method stringByReplacingOccurrencesOfString:@"::" withString:@"."]
//					stringByReplacingOccurrencesOfString:@":" withString:@"."]];
//			[item setMethod:[item className]];
//		}
//		else if ([className rangeOfString:@"."].location != NSNotFound && 
//			[className rangeOfString:@":"].location == NSNotFound)
//		{
//			// package found, but no classname (call from constructor)
//			[item setFQClassName:[NSString stringWithFormat:@"%@.%@", className, method]];
//		}
//		[stackItems addObject:item];
//		[item release];
	}
	return stackItems;
}

@end