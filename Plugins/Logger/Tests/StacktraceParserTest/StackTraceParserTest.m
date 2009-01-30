//
//  StackTraceParserTest.m
//  Trazzle
//
//  Created by Marc Bauer on 26.06.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "StackTraceParserTest.h"
#import "StackTraceParser.h"
#import "StackTraceItem.h"

@interface StackTraceParserTest (Private)
- (void)doTestStacktrace:(NSString *)stackTraceString forFQClassName:(NSString *)fqClassName
	method:(NSString *)method file:(NSString *)file line:(int)line;
@end


@implementation StackTraceParserTest

- (void)testStacktraceWithGlobalFunction
{
	[self doTestStacktrace:@"\n\tat global/log()[/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/log.as:7]" 
		forFQClassName:@"global" method:@"log" 
		file:@"/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/log.as" line:7];
}

- (void)testStacktraceWithConstructor
{
	[self doTestStacktrace:@"\n\tat TestApplication()[/Users/mb/Desktop/Contexts/3_nesiumdotcom/content/AS3_Demo_project/src/TestApplication.as:13]" 
		forFQClassName:@"TestApplication" method:@"TestApplication" 
		file:@"/Users/mb/Desktop/Contexts/3_nesiumdotcom/content/AS3_Demo_project/src/TestApplication.as" line:13];
}

- (void)testStacktraceWithConstructorAndPackage
{
	[self doTestStacktrace:@"\n\tat com.nesium.as3demo::DemoApplication()[/Users/mb/Desktop/AS3_Demo_project/src/com/nesium/as3demo/DemoApplication.as:15]" 
		forFQClassName:@"com.nesium.as3demo.DemoApplication" method:@"DemoApplication" 
		file:@"/Users/mb/Desktop/AS3_Demo_project/src/com/nesium/as3demo/DemoApplication.as" line:15];
}

- (void)testStacktraceWithExtendedInformation
{
	[self doTestStacktrace:@"\n\tat com.nesium.logging::TrazzleLogger/com.nesium.logging:TrazzleLogger::send()[/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/com/nesium/logging/TrazzleLogger.as:46]" 
		forFQClassName:@"com.nesium.logging.TrazzleLogger" method:@"send" 
		file:@"/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/com/nesium/logging/TrazzleLogger.as" 
		line:46];
}

- (void)testStacktraceWithNormalAttributes
{
	[self doTestStacktrace:@"\n\tat com.nesium.logging::TrazzleLogger/send()[/Users/mb/Desktop/Contexts/3_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/com/nesium/logging/TrazzleLogger.as:48]"
		forFQClassName:@"com.nesium.logging.TrazzleLogger" method:@"send" 
		file:@"/Users/mb/Desktop/Contexts/3_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/com/nesium/logging/TrazzleLogger.as" 
		line:48];
}

- (void)testStacktraceWithSingleDollarSign
{
	[self doTestStacktrace:@"\n\tat com.nivea.sweepstake::SweepstakeApp$iinit()[/Projekte/Nivea/Sweepstake_Form_AS3/trunk/src/com/nivea/sweepstake/SweepstakeApp.as:35]" 
		forFQClassName:@"com.nivea.sweepstake.SweepstakeApp" method:@"init" 
		file:@"/Projekte/Nivea/Sweepstake_Form_AS3/trunk/src/com/nivea/sweepstake/SweepstakeApp.as" 
		line:35];
}

- (void)testStacktraceWithMultipleDollarSigns
{
	[self doTestStacktrace:@"\n\tat TrazzleLogger.as$0::StackTrace$iinit()[/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/com/nesium/logging/TrazzleLogger.as:184]" 
		forFQClassName:@"StackTrace" method:@"init" 
		file:@"/Projekte/Nivea/Sweepstake_Form_AS3/trunk/lib/trazzle/com/nesium/logging/TrazzleLogger.as" 
		line:184];
}

- (void)testStacktraceWithStaticFunction
{
	[self doTestStacktrace:@"\n\tat com.nesium.as3demo::TestClass$/testStaticFunction()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/src/com/nesium/as3demo/TestClass.as:22]" 
		forFQClassName:@"com.nesium.as3demo.TestClass" method:@"testStaticFunction" 
		file:@"/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/src/com/nesium/as3demo/TestClass.as" 
		line:22];
}

- (void)doTestStacktrace:(NSString *)stackTraceString forFQClassName:(NSString *)fqClassName
	method:(NSString *)method file:(NSString *)file line:(int)line
{
	StackTraceItem *item = [[StackTraceParser parseAS3StackTrace:stackTraceString] objectAtIndex:0];
	STAssertTrue([[item fqClassName] isEqualToString:fqClassName], 
		@"FQClassname should be %@, but is %@", fqClassName, [item fqClassName]);
	STAssertTrue([[item method] isEqualToString:method], 
		@"Method should be %@, but is %@", method, [item method]);
	STAssertTrue([[item file] isEqualToString:file], 
		@"Filename should be %@, but is %@", file, [item file]);
	STAssertEquals((int)[item line], (int)line, 
		@"Line should be %d, but is %d", line, [item line]);
}

@end