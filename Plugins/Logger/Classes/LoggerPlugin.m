//
//  PluginController.m
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggerPlugin.h"

@implementation LoggerPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:3456] forKey:@"LPServerPort"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPEnableFiltering"];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:@"LPClearMessagesOnConnection"];
	[dict setObject:[NSNumber numberWithInt:WBMBringToTop] 
		forKey:@"LPWindowBehaviour"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"LPDebuggingMode"];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (id)initWithPlugInController:(PlugInController *)aController
{
	if (self = [super init])
	{
		controller = aController;
		m_loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LogWindow" 
			bundle:[NSBundle bundleForClass:[self class]]];
		m_loggingViewController.delegate = self;
		[controller addTabWithIdentifier:@"Foo" title:@"Test Tab" 
			view:[m_loggingViewController view]];
		m_messageModel = [[MessageModel alloc] init];
		m_messageModel.delegate = self;
		[m_messageModel startListening];
	}
	return self;
}

- (void)dealloc
{
	[m_messageModel release];
	[super dealloc];
}



#pragma mark -
#pragma mark MessageModel delegate methods

- (void)messageModel:(MessageModel *)model didReceiveMessage:(AbstractMessage *)message
{
	switch (message.messageType)
	{
		case kLPMessageTypeSocket:
		case kLPMessageTypeFlashLog:
			[m_loggingViewController sendMessage:message];
			break;
	}
}



#pragma mark -
#pragma mark LoggingViewController delegate methods

- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
	messageAtIndex:(uint32_t)index
{
	return [m_messageModel messageAtIndex:index];
}

@end