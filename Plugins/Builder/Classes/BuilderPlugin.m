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
- (void)_appendString:(NSString *)str withColor:(NSColor *)color;
- (void)_parseFileURLsInString:(NSString *)str;
@end


@implementation BuilderPlugin

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		m_historyIndex = 0;
		m_commandHistory = [[NSMutableArray alloc] init];
	
		[NSBundle loadNibNamed:@"CompilerShellView" owner:self];
		NSFont *font = [NSFont fontWithName:@"Monaco" size:10.0];
		[m_compilerOutputText setFont:font];
		[m_compilerOutputText setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, 
			[NSCursor pointingHandCursor], NSCursorAttributeName, nil]];
		[m_compilerOutputText setString:@""];
		[m_compilerOutputText setDelegate:self];
		[m_commandInputText setDelegate:self];
	
		controller = aController;
		[controller addTabWithIdentifier:@"BuilderMain" view:m_compilerOutputView  
			delegate:self];
		m_compilerSettingsController = [[BLDCompilerSettingsWindowController alloc] init];
		
		m_fcshTask = [[NSTask alloc] init];
		m_fcshInPipe = [[NSPipe alloc] init];
		m_fcshOutPipe = [[NSPipe alloc] init];
		m_fcshErrorPipe = [[NSPipe alloc] init];
		[m_fcshTask setLaunchPath:@"/usr/local/flexsdk/bin/fcsh"];
		[m_fcshTask setStandardInput:m_fcshOutPipe];
		[m_fcshTask setStandardOutput:m_fcshInPipe];
		[m_fcshTask setStandardError:m_fcshErrorPipe];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_fcshInPipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorDataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_fcshErrorPipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) 
			name:NSTaskDidTerminateNotification object:m_fcshTask];
			
		[m_fcshTask launch];
		[[m_fcshInPipe fileHandleForReading] readInBackgroundAndNotify];
		[[m_fcshErrorPipe fileHandleForReading] readInBackgroundAndNotify];
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
	[self _appendString:str withColor:[NSColor colorWithCalibratedRed:0.463 green:0.812 
		blue:0.980 alpha:1.0]];
}

- (void)_appendString:(NSString *)str withColor:(NSColor *)color
{
	NSRange endRange = (NSRange){[[m_compilerOutputText textStorage] length], 0};
	[m_compilerOutputText replaceCharactersInRange:endRange withString:str];
	endRange.length = [str length];
	
	NSUInteger strLen = [[m_compilerOutputText string] length];
	[m_compilerOutputText setTextColor:color range:(NSRange){strLen - [str length], [str length]}];
	
	RKEnumerator *enumerator = [str matchEnumeratorWithRegex:@"(\\/\\S*\\.\\w+)(?:\\((\\d+)\\): col: (\\d+))?"];
	NSFont *font = [NSFont fontWithName:@"Monaco" size:10.0];
	while ([enumerator nextRanges] != NULL)
	{
		NSString *filePath = nil, *line = nil, *col = nil;
		[enumerator getCapturesWithReferences:@"$1", &filePath, @"$2", &line, @"$3", &col, nil];
		NSURL *url;
		if (line == nil || col == nil)
			url = [NSURL fileURLWithPath:filePath];
		else
		{
			filePath = [NSString stringWithFormat:@"file://%@", filePath];
			NSString *escapedFilePath = (NSString *)CFURLCreateStringByAddingPercentEscapes(
				kCFAllocatorDefault, (CFStringRef)filePath, NULL, CFSTR("/"), kCFStringEncodingUTF8);
			url = [NSURL URLWithString:[NSString stringWithFormat:@"txmt://open?url=%@&line=%@&col=%@", 
				escapedFilePath, line, col]];
			CFRelease((CFStringRef)escapedFilePath);
		}
		NSColor *textColor = color;
		if ([[[filePath pathExtension] lowercaseString] isEqual:@"swf"] && [str hasPrefix:@"/"])
		{
			textColor = [NSColor colorWithCalibratedRed:0.651 green:0.886 blue:0.180 alpha:1.0];
		}
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			url, NSLinkAttributeName, 
			font, NSFontAttributeName, 
			textColor, NSForegroundColorAttributeName, 
			nil];
		NSRange linkRange = [enumerator currentRange];
		linkRange.location += endRange.location;
		[[m_compilerOutputText textStorage] setAttributes:attributes range:linkRange];
	}
	[m_compilerOutputText scrollRangeToVisible:endRange];
}

- (void)_parseFileURLsInString:(NSString *)str
{
	// /Projekte/Rittersport/RSFPlatform/src/de/rsf/components/windows/DraggableWindow.as(209): col: 24
	// /Projekte/Rittersport/RSFPlatform/src/de/rsf/components/windows/DraggableWindow.as
	// /Projekte/Rittersport/RSFPlatform/modules/signup/bin/SignupApp-debug.swf
}

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(unsigned)charIndex
{
	[[NSWorkspace sharedWorkspace] openURL:(NSURL *)link];
	return YES;
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

- (void)errorDataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self _appendString:message withColor:[NSColor redColor]];
	[[m_fcshErrorPipe fileHandleForReading] readInBackgroundAndNotify];
	[message release];
}

@end