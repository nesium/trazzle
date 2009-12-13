//
//  LPTailTask.m
//  Logger
//
//  Created by Marc Bauer on 13.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPTailTask.h"

@interface LPTailTask (Private)
- (void)_processBuffer;
@end


@implementation LPTailTask

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithFile:(NSString *)aPath delegate:(id)aDelegate{
	if (self = [super init]){
		m_path = [aPath retain];
		m_delegate = aDelegate;
		m_task = [[NSTask alloc] init];
		m_pipe = [[NSPipe alloc] init];
		[m_task setLaunchPath:@"/usr/bin/tail"];
		[m_task setArguments:[NSArray arrayWithObjects:@"-F", @"-n", @"0", m_path, nil]];
		[m_task setStandardOutput:m_pipe];
		m_buffer = [[NSMutableString alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_pipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_taskTerminated:) 
			name:NSTaskDidTerminateNotification object:m_task];
		
		// create file if needed
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:m_path])
			[fm createFileAtPath:m_path contents:nil attributes:nil];
	}
	return self;
}

- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[m_path release];
	[m_task terminate];
	[m_task release];
	m_task = nil;
	[m_pipe release];
	m_pipe = nil;
	[m_buffer release];
	m_buffer = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)launch{
	[m_task launch];
	[[m_pipe fileHandleForReading] readInBackgroundAndNotify];
}

- (void)terminate{
	[m_task terminate];
}



#pragma mark -
#pragma mark Private methods

- (void)_processBuffer{
	NSRange nlRange = [m_buffer rangeOfString:@"\n"];
	NSUInteger lastIndex = 0;
	NSUInteger strLen = [m_buffer length];
	BOOL delegateResponds = [m_delegate respondsToSelector:@selector(tailTask:didReceiveLine:)];
	while (nlRange.location != NSNotFound){
		NSString *line = [m_buffer substringWithRange:
			(NSRange){lastIndex, nlRange.location - lastIndex}];
		lastIndex = NSMaxRange(nlRange);
		nlRange = [m_buffer rangeOfString:@"\n" options:0 
			range:(NSRange){lastIndex, strLen - lastIndex}];
		if (delegateResponds)
			[m_delegate tailTask:self didReceiveLine:line];
	}
	[m_buffer deleteCharactersInRange:(NSRange){0, lastIndex}];
}



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)_taskTerminated:(NSNotification *)notification{
}

- (void)_dataAvailable:(NSNotification *)notification{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
	[m_buffer appendString:message];
	[self _processBuffer];
	[message release];
	[[m_pipe fileHandleForReading] readInBackgroundAndNotify];
}
@end