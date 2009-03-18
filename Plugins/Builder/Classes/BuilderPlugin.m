//
//  BuilderPlugin.m
//  Builder
//
//  Created by Marc Bauer on 16.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "BuilderPlugin.h"


@interface BuilderPlugin (Private)
- (void)_appendString:(NSString *)str;
@end


@implementation BuilderPlugin

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_historyIndex = 0;
		m_commandHistory = [[NSMutableArray alloc] init];
	
		[NSBundle loadNibNamed:@"CompilerShellView" owner:self];
		[m_compilerOutputText setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
		[m_compilerOutputText setTextColor:[NSColor colorWithCalibratedRed:0.463 green:0.812 
			blue:0.980 alpha:1.0]];
		[m_compilerOutputText setString:@""];
		[m_commandInputText setDelegate:self];
	
		controller = aController;
		[controller addTabWithIdentifier:@"BuilderMain" view:m_compilerOutputView  
			delegate:self];
		m_compilerSettingsController = [[BLDCompilerSettingsWindowController alloc] init];
		
		m_fcshTask = [[NSTask alloc] init];
		m_fcshInPipe = [[NSPipe alloc] init];
		m_fcshOutPipe = [[NSPipe alloc] init];
		[m_fcshTask setLaunchPath:@"/usr/local/flexsdk/bin/fcsh"];
		[m_fcshTask setStandardInput:m_fcshOutPipe];
		[m_fcshTask setStandardOutput:m_fcshInPipe];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_fcshInPipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) 
			name:NSTaskDidTerminateNotification object:m_fcshTask];
			
		[m_fcshTask launch];
		[[m_fcshInPipe fileHandleForReading] readInBackgroundAndNotify];
	}
	return self;
}

- (NSString *)titleForTabWithIdentifier:(NSString *)identifier
{
	return @"Compiler Shell";
}


- (IBAction)sendCommand:(id)sender
{
	[m_commandHistory addObject:[sender stringValue]];
	m_historyIndex = [m_commandHistory count];
	NSString *cmd = [NSString stringWithFormat:@"%@\n", [sender stringValue]];
	[sender setStringValue:@""];
	[[m_fcshOutPipe fileHandleForWriting] writeData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
	[self _appendString:cmd];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView 
	doCommandBySelector:(SEL)commandSelector 
{
	NSString *method = NSStringFromSelector(commandSelector);
	if ([method isEqual:@"moveUp:"])
	{
		if (m_historyIndex > 0)
		{
			m_historyIndex--;
			[m_commandInputText setStringValue:[m_commandHistory objectAtIndex:m_historyIndex]];
		}
		return YES;
	}
	else if ([method isEqual:@"moveDown:"])
	{
		if (m_historyIndex < [m_commandHistory count])
		{
			NSString *cmd;
			m_historyIndex++;
			if (m_historyIndex == [m_commandHistory count])
				cmd = @"";
			else
				cmd = [m_commandHistory objectAtIndex:m_historyIndex];
		}
		return YES;
	}
	return NO;
}


- (void)_appendString:(NSString *)str
{
	[m_compilerOutputText setString:[[m_compilerOutputText string] stringByAppendingString:str]];
	NSUInteger strLen = [[m_compilerOutputText string] length];
	[m_compilerOutputText scrollRangeToVisible:(NSRange){strLen - 1, strLen}];
}


#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification
{
}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self _appendString:message];
	[[m_fcshInPipe fileHandleForReading] readInBackgroundAndNotify];
	[message release];
}

@end