//
//  LPMMCfgFile.m
//  Logger
//
//  Created by Marc Bauer on 12.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPMMCfgFile.h"

NSString *const kMMCfgGlobalPath = @"/Library/Application Support/Macromedia/mm.cfg";
NSString *const kMMCfgLocalPath = @"~/mm.cfg";

@implementation LPMMCfgFile

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super init]){
		m_settings = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithContentsOfFile:(NSString *)aPath error:(NSError **)error{
	if (self = [self init]){
		NSMutableString *contents = [NSMutableString stringWithContentsOfFile:aPath 
			encoding:NSUTF8StringEncoding error:error];
		if (!contents){
			[self release];
			return nil;
		}
		[contents replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 
			range:(NSRange){0, [contents length]}];		
		[contents replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 
			range:(NSRange){0, [contents length]}];
		NSArray *lines = [contents componentsSeparatedByString:@"\n"];
		NSCharacterSet *wsSet = [NSCharacterSet whitespaceCharacterSet];
		for (NSString *line in lines){
			NSRange equalSignRange = [line rangeOfString:@"="];
			if (equalSignRange.location == NSNotFound)
				continue;
			NSString *key = [line substringToIndex:equalSignRange.location];
			NSString *value = [line substringFromIndex:equalSignRange.location + 
				equalSignRange.length];
			key = [key stringByTrimmingCharactersInSet:wsSet];
			value = [value stringByTrimmingCharactersInSet:wsSet];
			[m_settings setObject:value forKey:key];
		}
	}
	return self;
}

+ (id)mmCfg{
	return [[[[self class] alloc] init] autorelease];
}

+ (id)mmCfgWithContentsOfFile:(NSString *)aPath error:(NSError **)error{
	return [[[[self class] alloc] initWithContentsOfFile:aPath error:error] autorelease];
}

- (void)dealloc{
	[m_settings release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)writeToFile:(NSString *)aPath atomically:(BOOL)atomically error:(NSError **)error{
	NSMutableString *contents = [NSMutableString string];
	NSArray *keys = [[m_settings allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSUInteger len = [keys count];
	for (NSUInteger i = 0; i < len; i++){
		NSString *key = [keys objectAtIndex:i];
		[contents appendFormat:@"%@=%@", key, [m_settings objectForKey:key]];
		if (i < len - 1) [contents appendString:@"\n"];
	}
	return [contents writeToFile:aPath atomically:atomically encoding:NSUTF8StringEncoding 
		error:error];
}

- (id)valueForKey:(NSString *)key{
	return [m_settings valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key{
	[m_settings setValue:value forKey:key];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues{
	[m_settings setValuesForKeysWithDictionary:keyedValues];
}
@end