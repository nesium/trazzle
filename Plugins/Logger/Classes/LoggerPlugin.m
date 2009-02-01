//
//  PluginController.m
//  Logger
//
//  Created by Marc Bauer on 19.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggerPlugin.h"

@interface LoggerPlugin (Private)
- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client;
- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client;
@end


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
		
		// display viewcontroller
		m_loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LogWindow" 
			bundle:[NSBundle bundleForClass:[self class]]];
		m_loggingViewController.delegate = self;
		[controller addTabWithIdentifier:@"Foo" title:@"Test Tab" 
			view:[m_loggingViewController view]];
		
		// alloc model
		m_messageModel = [[MessageModel alloc] init];
		m_messageModel.delegate = self;
		
		// start server
		m_connectedClients = [[NSMutableArray alloc] init];
		NSError *error;
		uint16_t port = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
			valueForKey:@"LPServerPort"] shortValue];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		if (![m_socket acceptOnPort:port error:&error])
		{
			NSLog(@"Could not start server on port %d", port);
		}
		
		// tail flashlog
		m_tailTask = [[NSTask alloc] init];
		m_logPipe = [[NSPipe alloc] init];
		[m_tailTask setLaunchPath:@"/usr/bin/tail"];
		[m_tailTask setArguments:[NSArray arrayWithObjects:@"-F", 
			[@"~/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt" 
				stringByExpandingTildeInPath], nil]];
		[m_tailTask setStandardOutput:m_logPipe];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) 
			name:NSFileHandleReadCompletionNotification object:[m_logPipe fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) 
			name:NSTaskDidTerminateNotification object:m_tailTask];
			
		[m_tailTask launch];
		[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[m_connectedClients release];
	[m_messageModel release];
	[super dealloc];
}



#pragma mark -
#pragma mark Private methods

- (void)_handleMessage:(AbstractMessage *)msg fromClient:(LoggingClient *)client
{
	[m_loggingViewController sendMessage:msg];
}

- (void)_handleCommandMessage:(CommandMessage *)msg fromClient:(LoggingClient *)client
{
	if (msg.type == kCommandActionTypeUpdateStatusBar)
	{
		if (client.statusMenuItem)
		{
			[controller removeStatusMenuItem:client.statusMenuItem];
		}
		if (msg.data)
		{
			client.statusMenuItem = [[NSMenuItem alloc] init];
			[client.statusMenuItem setTitle:@"Untitled"];
			NSMenu *menu = [[NSMenu alloc] init];
			[client.statusMenuItem setSubmenu:menu];
			for (NSMenuItem *menuItem in (NSArray *)msg.data)
			{
				[menu addItem:menuItem];
			}
			[menu release];
		}
		else
		{
			client.statusMenuItem = nil;
		}
		if (client.statusMenuItem)
		{
			[controller addStatusMenuItem:client.statusMenuItem];
		}
	}
}



#pragma mark -
#pragma mark NSTask and NSFileHandle Notifications

- (void)taskTerminated:(NSNotification *)notification
{
}

- (void)dataAvailable:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
	NSString *message = [NSString stringWithUTF8String:[data bytes]];
	[self _handleMessage:[AbstractMessage messageWithType:kLPMessageTypeFlashLog 
		message:message] fromClient:nil];
	[[m_logPipe fileHandleForReading] readInBackgroundAndNotify];
}



#pragma mark -
#pragma mark AsyncSocket delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	LoggingClient *client = [[LoggingClient alloc] initWithSocket:newSocket];
	client.delegate = self;
	[m_connectedClients addObject:client];
	[client release];
}



#pragma mark -
#pragma mark LoggingClient delegate methods

- (void)client:(LoggingClient *)client didReceiveMessage:(NSString *)message
{
	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message delegate:self];
	AbstractMessage *msg = (AbstractMessage *)[[parser data] objectAtIndex:0];

	if (msg.messageType == kLPMessageTypeCommand)
	{
		[self _handleCommandMessage:(CommandMessage *)msg fromClient:client];
	}
	else
	{
		[self _handleMessage:msg fromClient:client];
	}
	[parser release];
}

- (void)clientDidDisconnect:(LoggingClient *)client
{
	if (client.statusMenuItem)
	{
		[controller removeStatusMenuItem:client.statusMenuItem];
	}
	[m_connectedClients removeObject:client];
}



#pragma mark -
#pragma mark LoggingViewController delegate methods

- (AbstractMessage *)loggingViewController:(LoggingViewController *)controller 
	messageAtIndex:(uint32_t)index
{
	return [m_messageModel messageAtIndex:index];
}



#pragma mark -
#pragma mark MessageParser delegate methods

- (void)parser:(MessageParser *)parser didParseMenuItem:(NSMenuItem *)menuItem
{
	[menuItem setTarget:self];
	[menuItem setAction:@selector(statusMenuItemWasClicked:)];
}



#pragma mark -
#pragma mark StatusMenuItem actions

- (void)statusMenuItemWasClicked:(NSMenuItem *)sender
{
	NSMenu *lastMenu = [sender menu];
	NSMenu *parent = [lastMenu supermenu];
	NSMutableArray *indexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:
		[lastMenu indexOfItem:sender]]];
	while (parent)
	{
		for (LoggingClient *client in m_connectedClients)
		{
			if ([client.statusMenuItem menu] == parent)
			{
				[client sendEventWithType:kEventStatusItemClicked attributes:
					[NSDictionary dictionaryWithObject:[indexes componentsJoinedByString:@"-"] 
						forKey:@"indexes"]];
				return;
			}
		}
	
		for (int32_t i = 0; i < [[parent itemArray] count]; i++)
		{
			NSMenuItem *item = [[parent itemArray] objectAtIndex:i];
			if ([item submenu] == lastMenu)
			{
				[indexes insertObject:[NSNumber numberWithInt:i] atIndex:0];
			}
		}
		
		lastMenu = parent;
		parent = [lastMenu supermenu];
	}
}

@end