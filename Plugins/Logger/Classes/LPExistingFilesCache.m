//
//  LPExistingFilesCache.m
//  Logger
//
//  Created by Marc Bauer on 28.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPExistingFilesCache.h"

static LPExistingFilesCache *g_sharedInstance;

@implementation LPExistingFilesCache

#pragma mark -
#pragma mark Initialization & Deallocation

+ (LPExistingFilesCache *)sharedCache
{
	return g_sharedInstance ?: [[self new] autorelease];
}

- (id)init
{
	if (g_sharedInstance)
	{
		[self release];
	}
	else if (self = g_sharedInstance = [[super init] retain])
	{
		m_filesCache = [[NSMutableDictionary alloc] init];
	}
	return g_sharedInstance;
}



#pragma mark -
#pragma mark Public methods

- (BOOL)fileExistsAtPath:(NSString *)path
{
	NSNumber *value = [m_filesCache objectForKey:path];
	if (value == nil)
	{
		BOOL isDirectory;
		value = [NSNumber numberWithBool:([[NSFileManager defaultManager] fileExistsAtPath:path 
			isDirectory:&isDirectory] && !isDirectory)];
		[m_filesCache setObject:value forKey:path];
	}
	return [value boolValue];
}
@end