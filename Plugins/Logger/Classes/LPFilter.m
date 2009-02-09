//
//  LPFilter.m
//  Logger
//
//  Created by Marc Bauer on 08.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPFilter.h"

@interface LPFilter (Private)
- (BOOL)writeToFile:(NSString *)path error:(NSError **)error;
- (NSString *)normalizedName;
- (void)setPath:(NSString *)path;
- (NSString *)nextAvailableFilename;
@end

@implementation LPFilter

@synthesize predicate=m_predicate, name=m_name;

#pragma mark -
#pragma mark Initialization & deallocation

- (id)initWithName:(NSString *)name predicate:(NSPredicate *)predicate
{
	self = [super init];
	self.name = name;
	self.predicate = predicate;
	m_isDirty = YES;
	m_wantsRenaming = NO;
	return self;
}

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSString *errorString;
	NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *doc = [NSPropertyListSerialization propertyListFromData:data 
		mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorString];

    if (doc) 
	{
		self = [self initWithName:[doc objectForKey:kFilterName] 
			predicate:[NSPredicate predicateWithFormat:[doc objectForKey:kFilterPredicate]]];
    } 
	else 
	{
		NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"Trazzle filter couldn't be read (%@)", path], 
			NSLocalizedDescriptionKey, 
			(errorString ? errorString : @"An unknown error occured."), 
			NSLocalizedFailureReasonErrorKey, nil];
		*error = [NSError errorWithDomain:@"TrazzleErrorDomain" code:-1 userInfo:errorUserInfo];
        [errorString release];
		return nil;
    }
	
	[self setPath:path];
	m_isDirty = NO;
	return self;
}

- (void)dealloc
{
	[m_predicate release];
	[m_name release];
	[m_path release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08x>", [self className], (long)self];
}

- (void)setName:(NSString *)name
{
	if ([m_name isEqualToString:name])
	{
		return;
	}
	m_isDirty = YES;
	m_wantsRenaming = YES;
	[name retain];
	[m_name release];
	m_name = name;
}

- (NSString *)path
{
	return m_path;
}

- (void)setPredicate:(NSPredicate *)predicate
{
	if ([m_predicate isEqual:predicate])
	{
		return;
	}
	m_isDirty = YES;
	[predicate retain];
	[m_predicate release];
	m_predicate = predicate;
}

- (BOOL)isDirty
{
	return m_isDirty;
}

- (BOOL)save:(NSError **)error
{
	if (m_wantsRenaming)
	{
		[self unlink:error];
	}
	if ([self path] == nil)
	{
		[self setPath:[self nextAvailableFilename]];
	}
	return [self writeToFile:[self path] error:error];
}

- (BOOL)unlink:(NSError **)error
{
	BOOL isDir;
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:[self path] isDirectory:&isDir] || isDir)
	{
		return NO;
	}
	BOOL success = [fm removeItemAtPath:[self path] error:error];
	if (success)
	{
		[self setPath:nil];
		m_wantsRenaming = NO;
	}
	return success;
}



#pragma mark -
#pragma mark Private methods

- (BOOL)writeToFile:(NSString *)path error:(NSError **)error
{
	NSData *data;
	NSMutableDictionary *doc = [NSMutableDictionary dictionary];
	NSString *errorString;
	[doc setObject:[self name] forKey:kFilterName];
	[doc setObject:[[self predicate] predicateFormat] forKey:kFilterPredicate];
	[doc setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
		forKey:kFilterVersion];
	data = [NSPropertyListSerialization dataFromPropertyList:doc 
		format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];

	if (!data) 
	{
		NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Trazzle filter couldn't be written", NSLocalizedDescriptionKey, 
			(errorString ? errorString : @"An unknown error occured."), 
			NSLocalizedFailureReasonErrorKey, nil];
		*error = [NSError errorWithDomain:@"TrazzleErrorDomain" code:-1 userInfo:errorUserInfo];
		[errorString release];
		return NO;
	}
	BOOL success = [data writeToFile:path options:0 error:error];
	if (success)
	{
		m_isDirty = NO;
	}
	return success;
}

- (NSString *)normalizedName
{
	NSMutableString *name = [NSMutableString stringWithString: [self name]];
	[name replaceOccurrencesOfString:@":" withString:@"-" 
		options:0 range:NSMakeRange(0, [[self name] length])];
	[name replaceOccurrencesOfString:@"/" withString:@":" 
		options:0 range:NSMakeRange(0, [[self name] length])];
	return [name precomposedStringWithCanonicalMapping];
}

- (NSString *)nextAvailableFilename
{
	NSString *proposedFilename = [[TRAZZLE_APP_SUPPORT stringByAppendingPathComponent:@"Filters"] 
		stringByAppendingPathComponent:[self normalizedName]];
	NSString *usedFilename = proposedFilename;
		
	unsigned int i = 1;
	while ([[NSFileManager defaultManager] 
		fileExistsAtPath:[usedFilename stringByAppendingPathExtension:kFilterFileExtension]])
	{
		usedFilename = [NSString stringWithFormat:@"%@-%d", proposedFilename, i++];
	}
	return [usedFilename stringByAppendingPathExtension:kFilterFileExtension];
}

- (void)setPath:(NSString *)path
{
	[path retain];
	[m_path release];
	m_path = path;
}

@end