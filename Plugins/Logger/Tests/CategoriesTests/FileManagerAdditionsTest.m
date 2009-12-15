//
//  FileManagerAdditionsTest.m
//  Logger
//
//  Created by Marc Bauer on 15.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FileManagerAdditionsTest.h"


@implementation FileManagerAdditionsTest

- (void)testNextAvailableFilename{
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] globallyUniqueString]];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath:tmpPath attributes:nil];

	// check next filename	
	NSString *filename = @"test.txt";
	NSString *resultingFilename = [fm nextAvailableFilenameAtPath:tmpPath proposedFilename:filename];
	GHAssertEqualStrings(filename, resultingFilename, @"Filenames should be equal");
	
	// create empty file
	BOOL success = [fm createFileAtPath:[tmpPath stringByAppendingPathComponent:filename] 
		contents:nil attributes:nil];
	GHAssertTrue(success, @"Could not create empty file");
	
	// check next filename
	resultingFilename = [fm nextAvailableFilenameAtPath:tmpPath proposedFilename:filename];
	GHAssertEqualStrings(@"test-1.txt", resultingFilename, @"Filenames should be equal");
	
	// create empty file
	success = [fm createFileAtPath:[tmpPath stringByAppendingPathComponent:resultingFilename] 
		contents:nil attributes:nil];
	GHAssertTrue(success, @"Could not create (second) empty file");
	
	// check next filename
	resultingFilename = [fm nextAvailableFilenameAtPath:tmpPath proposedFilename:filename];
	GHAssertEqualStrings(@"test-2.txt", resultingFilename, @"Filenames should be equal");
	
	// delete first created file
	success = [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"test-1.txt"] error:nil];
	GHAssertTrue(success, @"Could not delete empty file");
	
	// check next filename again
	resultingFilename = [fm nextAvailableFilenameAtPath:tmpPath proposedFilename:filename];
	GHAssertEqualStrings(@"test-1.txt", resultingFilename, @"Filenames should be equal");
}
@end