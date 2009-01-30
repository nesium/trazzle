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
		NSString *line = [[lines objectAtIndex:i] substringFromIndex:4]; // ignore @"\tat "
		NSString *className = nil, *package = nil, *method = nil, *file = nil, *lineNo = nil;
		NSRange firstBracketRange = [line rangeOfString:@"["];
		if (firstBracketRange.location != NSNotFound)
		{
			// movie was most likely compiled with verbose-stacktraces
			NSRange lastBracketRange = [line rangeOfString:@"]" options:NSBackwardsSearch];
			if (lastBracketRange.location != NSNotFound)
			{
				NSString *chunk = [line substringWithRange:(NSRange){firstBracketRange.location + 1, 
					lastBracketRange.location - firstBracketRange.location - 1}];
				NSRange colonRange = [chunk rangeOfString:@":" options:NSBackwardsSearch];
				if (colonRange.location != NSNotFound && colonRange.location < [chunk length] - 1)
				{
					file = [chunk substringToIndex:colonRange.location];
					lineNo = [chunk substringFromIndex:colonRange.location + 1];
				}
			}
			line = [line substringToIndex:firstBracketRange.location];
		}
		
		NSRange methodDividerRange = [line rangeOfString:@"/" options:NSBackwardsSearch];
		if (methodDividerRange.location == NSNotFound)
		{
			methodDividerRange = [line rangeOfString:@"$i" options:NSBackwardsSearch];
		}
		if (methodDividerRange.location != NSNotFound)
		{
			method = [line substringWithRange:(NSRange){methodDividerRange.location + 
				methodDividerRange.length, [line length] - methodDividerRange.location - 
				methodDividerRange.length - 2}]; // -2 = omit parantheses
			NSRange doubleColonRange = [method rangeOfString:@"::" options:NSBackwardsSearch];
			if (doubleColonRange.location != NSNotFound)
			{
				method = [method substringFromIndex:doubleColonRange.location + 2];
			}
			line = [line substringToIndex:methodDividerRange.location];
		}
		
		NSArray *classPackageParts = [line componentsSeparatedByString:@"::"];
		if ([classPackageParts count] == 1)
		{
			className = [classPackageParts objectAtIndex:0];
		}
		else
		{
			package = [classPackageParts objectAtIndex:0];
			className = [classPackageParts objectAtIndex:1];
		}
		
		if (className)
		{
			NSRange slashRange = [className rangeOfString:@"/"];
			if (slashRange.location != NSNotFound)
			{
				className = [className substringToIndex:slashRange.location];
			}
		
			if ([className length] > 2 && [[className substringFromIndex:[className length] - 2] 
				isEqualToString:@"()"])
			{
				className = [className substringToIndex:[className length] - 2];
			}
			else if ([className length] > 1 && [[className substringFromIndex:[className length] - 1]
				isEqualToString:@"$"])
			{
				className = [className substringToIndex:[className length] - 1];
			}
		}
		
		if (package)
		{
			NSRange asExtensionRange = [package rangeOfString:@".as$" options:NSBackwardsSearch];
			if (asExtensionRange.location != NSNotFound)
			{
				package = nil;
			}
		}
		
		NSMutableString *fqClassNameMutable = [NSMutableString string];
		if (package)
		{
			[fqClassNameMutable appendString:package];
			if (className)
			{
				[fqClassNameMutable appendString:@"."];
			}
		}
		if (className)
		{
			[fqClassNameMutable appendString:className];
		}
		NSString *fqClassName = [fqClassNameMutable copy];
		
		if (!method) // calls from constructor
		{
			method = className;
		}
		
		StackTraceItem *item = [[StackTraceItem alloc] init];
		[item setFQClassName:fqClassName];
		[item setMethod:method];
		[item setFile:file];
		[item setLine:[lineNo intValue]];
		[stackItems addObject:item];
		[fqClassName release];
		[item release];
	}
	return stackItems;
}

@end