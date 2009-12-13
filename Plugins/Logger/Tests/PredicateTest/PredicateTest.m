//
//  PredicateTest.m
//  Trazzle
//
//  Created by Marc Bauer on 17.12.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "PredicateTest.h"
#import "LPMessageModel.h"
#import "MessageParser.h"
#import "LPFilterModel.h"


@implementation PredicateTest

LPMessageModel *m_logMessageModel;

- (void) setUp
{
	// load testdata
	NSError *error = nil;
	NSString *testDataPath = [[[NSBundle bundleForClass: [PredicateTest class]] resourcePath] 
		stringByAppendingPathComponent: @"predicatetest_data.xml"];
	NSString *testData = [NSString stringWithContentsOfFile: testDataPath
		 encoding: NSUTF8StringEncoding error: &error];
	GHAssertNil(error, @"Test data could not be read. %@", [error description]);
	
	NSArray *lines = [testData componentsSeparatedByString: @"\n"];
	GHAssertEquals(496, (int)[lines count], 
		@"array should contain 496 items, but does contain %d items", [lines count]);
	
	// parse testdata & push into model
	m_logMessageModel = [[LPMessageModel alloc] init];
	
	NSEnumerator *lineEnum = [lines objectEnumerator];
	NSString *messageString;
	while (messageString = [lineEnum nextObject])
	{
		MessageParser *parser = [[MessageParser alloc] initWithXMLString: messageString];
		NSEnumerator *messageEnum = [[parser data] objectEnumerator];
		id message;
		
		while (message = [messageEnum nextObject]){
			[m_logMessageModel addMessage:message];
		}
		[parser release];
	}
	
	GHAssertEquals(496, (int)[[m_logMessageModel messages] count], 
	@"Model should contain 496 messages, but does contain %d messages", 
	[[m_logMessageModel messages] count]);
}

- (void)tearDown{
	[m_logMessageModel release];
}

- (void)testPredicateLoglevelEquals
{
	LPFilter *filter = [[LPFilterModel defaultModel] addFilterWithName:@"testPredicateLoglevelEquals" 
		predicate:[NSPredicate predicateWithFormat: @"level == 5"]];
	[[LPFilterModel defaultModel] setActiveFilter:filter];
	[[LPFilterModel defaultModel] setFilteringEnabled:[NSNumber numberWithBool:YES]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"visible == YES"];
	NSArray *filteredMessages = [[m_logMessageModel messages] 
		filteredArrayUsingPredicate: predicate];
	GHAssertEquals(2, (int)[filteredMessages count], @"filtered message should be 2, but is %d",
		[filteredMessages count]);
	[[LPFilterModel defaultModel] removeFilter:filter];
}

- (void) testPredicateClazzEndsWith
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"fqClassName ENDSWITH \"CSS\""];
	NSArray *filteredMessages = [[m_logMessageModel messages] 
		filteredArrayUsingPredicate: predicate];
	GHAssertEquals(1, (int)[filteredMessages count], @"filtered message should be 1, but is %d",
		[filteredMessages count]);	
}
- (void) testPredicateClazzEquals
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat: 
		@"fqClassName == \"de.rittersport.components.coverflow.Coverflow\""];
	NSArray *filteredMessages = [[m_logMessageModel messages] 
		filteredArrayUsingPredicate: predicate];
	GHAssertEquals(483, (int)[filteredMessages count], @"filtered message should be 483, but is %d",
		[filteredMessages count]);	
}
- (void) testPredicateClazzBeginsWith
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"fqClassName BEGINSWITH \"com\""];
	NSArray *filteredMessages = [[m_logMessageModel messages] 
		filteredArrayUsingPredicate: predicate];
	GHAssertEquals(10, (int)[filteredMessages count], @"filtered message should be 10, but is %d",
		[filteredMessages count]);	
}
- (void) testPredicateClazzMatches
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"fqClassName MATCHES \"de\\.fork\\..*\\.AbstractResource\""];
	NSArray *filteredMessages = [[m_logMessageModel messages] 
		filteredArrayUsingPredicate: predicate];
	GHAssertEquals(2, (int)[filteredMessages count], @"filtered message should be 2, but is %d",
		[filteredMessages count]);	
}

@end