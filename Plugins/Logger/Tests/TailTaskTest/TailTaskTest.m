//
//  TailTaskTest.m
//  Logger
//
//  Created by Marc Bauer on 13.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "TailTaskTest.h"


@implementation TailTaskTest

- (BOOL)shouldRunOnMainThread{
	return NO;
}

- (void)setUp{
	m_receivedLines = [[NSMutableArray alloc] init];
	m_sentLines = [[NSMutableArray alloc] init];
	
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
		[[NSProcessInfo processInfo] globallyUniqueString]];

	[self performSelectorOnMainThread:@selector(_startTailTask:) withObject:tmpPath waitUntilDone:YES];
	
	GHTestLog(@"path: %@", tmpPath);
	m_fileHandle = [[NSFileHandle fileHandleForWritingAtPath:tmpPath] retain];
}

- (void)_startTailTask:(NSString *)tmpPath{
	m_tailTask = [[LPTailTask alloc] initWithFile:tmpPath delegate:self];
	[m_tailTask launch];
}

- (void)_stopTailTask{
	[m_tailTask terminate];
	[m_tailTask release];
	m_tailTask = nil;
}

- (void)tearDown{
	[m_sentLines release];
	m_sentLines = nil;
	[m_receivedLines release];
	m_receivedLines = nil;
	[self performSelectorOnMainThread:@selector(_stopTailTask) withObject:nil waitUntilDone:YES];
	[m_fileHandle closeFile];
	[m_fileHandle release];
	m_fileHandle = nil;
}

- (void)testReceivingOfLines{
	NSString *testMsg = @"Error #2044: Unhandled ioError:. text=Error #2032: Stream Error. URL: file:///Daten/Projekte/suv/expotechnik/project/bin/xml/businessdivisions.xml\n\
	at reprise.external::FileResource/doLoad()[/Daten/Projekte/suv/expotechnik/project/lib/darkskies/reprise/external/FileResource.as:101]\n\
	at reprise.external::AbstractResource/notifyComplete()[/Daten/Projekte/suv/expotechnik/project/lib/darkskies/reprise/external/AbstractResource.as:285]\n\
	at reprise.external::AbstractResource/checkProgress()[/Daten/Projekte/suv/expotechnik/project/lib/darkskies/reprise/external/AbstractResource.as:237]\n\
	at Function/http://adobe.com/AS3/2006/builtin::apply()\n\
	at reprise.utils::Delegate/execute()[/Daten/Projekte/suv/expotechnik/project/lib/darkskies/reprise/utils/Delegate.as:47]\n\
	at reprise.commands::TimeCommandExecutor/executeWrappedCommand()[/Daten/Projekte/suv/expotechnik/project/lib/darkskies/reprise/commands/TimeCommandExecutor.as:167]\n\
	at Function/http://adobe.com/AS3/2006/builtin::apply()";
	NSArray *lines = [testMsg componentsSeparatedByString:@"\n"];
	
	[self prepare];
	
	int count = 0;
	for (uint i = 0; i < 300; i++){
		for (NSString *line in lines){
			line = [NSString stringWithFormat:@"%d - %@", count++, line];
			[m_fileHandle writeData:[[NSString stringWithFormat:@"%@\n", line] 
				dataUsingEncoding:NSMacOSRomanStringEncoding]];
			[m_sentLines addObject:line];
		}
	}
	sleep(3);
	NSEnumerator *linesEnum = [lines reverseObjectEnumerator];
	NSString *line;
	for (uint i = 0; i < 10; i++){
		while (line = [linesEnum nextObject]){
			line = [NSString stringWithFormat:@"%d - %@", count++, line];
			[m_fileHandle writeData:[[NSString stringWithFormat:@"%@\n", line] 
				dataUsingEncoding:NSMacOSRomanStringEncoding]];
			[m_sentLines addObject:line];
		}
	}
	[self performSelector:@selector(_finishTest) withObject:nil afterDelay:6.0];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)_finishTest{
	@synchronized(m_receivedLines){
		GHAssertEqualStrings([m_sentLines componentsJoinedByString:@""], 
			[m_receivedLines componentsJoinedByString:@""], 
			@"Sent lines and received lines should match");
	}
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testReceivingOfLines)];
}



#pragma mark -
#pragma mark TailTask delegate method

- (void)tailTask:(LPTailTask *)task didReceiveLine:(NSString *)line{
	@synchronized(m_receivedLines){
		[m_receivedLines addObject:line];
	}
}
@end