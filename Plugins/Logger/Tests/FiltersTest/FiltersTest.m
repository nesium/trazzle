//
//  FiltersTest.m
//  Logger
//
//  Created by Marc Bauer on 14.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FiltersTest.h"


@implementation FiltersTest

- (void)testSaveAndLoad{
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] globallyUniqueString]];
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL success = [fm createDirectoryAtPath:tmpPath attributes:nil];
	GHAssertTrue(success, @"Could not create tmp directory");
	
	// create filter
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"level == 6"];
	NSString *filterName = @"TestFilter";
	LPFilter *filter = [[LPFilter alloc] initWithName:filterName predicate:predicate];
	
	// write filter to disk
	NSError *error = nil;
	GHTestLog(tmpPath);
	success = [filter saveToDirectory:tmpPath error:&error];
	GHAssertTrue(success, @"Could not write filter to disk.");
	GHAssertNil(error, @"Error should be nil");
	
	// check if it exists
	NSString *filterFilename = [[tmpPath stringByAppendingPathComponent:filterName] 
		stringByAppendingPathExtension:kFilterFileExtension];
	BOOL fileExists = [fm fileExistsAtPath:filterFilename];
	GHAssertTrue(fileExists, @"Filter does not exist on disk");
	
	// load filter from disk
	error = nil;
	LPFilter *loadedFilter = [[LPFilter alloc] initWithContentsOfFile:filterFilename error:&error];
	GHAssertNotNil(loadedFilter, @"Loaded filter should not be nil");
	GHAssertNil(error, @"Error should be nil");
	
	// compare loaded filter with our initial data
	GHAssertEqualStrings(filterName, loadedFilter.name, @"Filter names should match");
	GHAssertEqualObjects(predicate, loadedFilter.predicate, @"Predicates should match (%@ vs. %@)", 
		[predicate predicateFormat], [loadedFilter.predicate predicateFormat]);
	
	[filter release];
	[loadedFilter release];
}

- (void)testReadFailure{
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] globallyUniqueString]];
	NSError *error = nil;
	LPFilter *filter = [[LPFilter alloc] initWithContentsOfFile:tmpPath error:&error];
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertNil(filter, @"Filter should be nil");
}
@end