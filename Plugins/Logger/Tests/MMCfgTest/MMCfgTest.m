//
//  MMCfgTest.m
//  Logger
//
//  Created by Marc Bauer on 12.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "MMCfgTest.h"


@implementation MMCfgTest

- (void)testReadMMCfg{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"mm" ofType:@"cfg"];
	NSError *error = nil;
	LPMMCfgFile *mmCfg = [LPMMCfgFile mmCfgWithContentsOfFile:path error:&error];
	GHAssertNil(error, @"Error should be nil. But is %@", error);
	GHAssertEqualStrings([mmCfg valueForKey:@"MaxWarnings"], @"0", @"MaxWarnings not equal");
	GHAssertEqualStrings([mmCfg valueForKey:@"TraceOutputEnable"], @"1", 
		@"TraceOutputEnable not equal");
	GHAssertEqualStrings([mmCfg valueForKey:@"TraceOutputFileName"], 
		@"/Users/mb/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt", 
		@"TraceOutputFileName not equal");
	GHAssertEqualStrings([mmCfg valueForKey:@"TraceOutputFileEnable"], @"1", 
		@"TraceOutputFileEnable not equal");
	GHAssertEqualStrings([mmCfg valueForKey:@"ErrorReportingEnable"], @"1", 
		@"ErrorReportingEnable not equal");
}

- (void)testFailReadMMCfg{
	NSString *path = @"/a/path/which/is/unlikely/to/exist/mm.cfg";
	NSError *error = nil;
	LPMMCfgFile *mmCfg = [LPMMCfgFile mmCfgWithContentsOfFile:path error:&error];
	GHAssertNil(mmCfg, @"mmCfg should be nil");
	GHAssertNotNil(error, @"error should not be nil");
}

- (void)testWriteMMCfg{
	LPMMCfgFile *mmCfg = [LPMMCfgFile mmCfg];
	[mmCfg setValue:@"0" forKey:@"MaxWarnings"];
	[mmCfg setValue:@"/path/to/file with space/flashlog.txt" forKey:@"TraceOutputFileName"];
	[mmCfg setValue:@"1" forKey:@"TraceOutputFileEnable"];
	[mmCfg setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		@"1", @"ErrorReportingEnable", @"1", @"TraceOutputEnable", nil]];
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] globallyUniqueString]];
	NSError *error = nil;
	BOOL success = [mmCfg writeToFile:tmpPath atomically:NO error:&error];
	GHAssertTrue(success, @"Success should be YES");
	GHAssertNil(error, @"Error should be nil");
	NSError *readError = nil;
	NSString *str = [NSString stringWithContentsOfFile:tmpPath encoding:NSUTF8StringEncoding 
		error:&readError];
	GHAssertNil(readError, @"readError should be nil");
	NSString *resultingString = @"ErrorReportingEnable=1\n\
MaxWarnings=0\n\
TraceOutputEnable=1\n\
TraceOutputFileEnable=1\n\
TraceOutputFileName=/path/to/file with space/flashlog.txt";
	GHAssertEqualStrings(str, resultingString, @"String read from disk should equal resultingString");
}
@end