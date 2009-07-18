//
//  FDBConnection.m
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FDBConnection.h"

#define kReadDataLengthTag 1
#define kReadDataTag 2

@interface FDBConnection (Private)
- (void)_initConnection;
- (void)_continueReading;
- (void)_sendMessage:(FDBMessage *)msg;
- (void)_sendOptionMessage:(NSString *)option value:(NSString *)value;
- (void)_sendSquelch:(BOOL)bFlag;
- (void)_handleMessage:(FDBMessage *)msg;
- (void)_addSourceModule:(FDBSourceModule *)module;
@end

@implementation FDBConnection

#pragma mark -
#pragma mark Initialization & Deallocation

+ (FDBConnection *)connectionWithSocket:(AsyncSocket *)socket
{
	return [[[FDBConnection alloc] initWithSocket:socket] autorelease];
}

- (id)initWithSocket:(AsyncSocket *)socket
{
	if (self = [super init])
	{
		m_socket = [socket retain];
		[m_socket setDelegate:self];
		m_sourceFiles = [[NSMutableArray alloc] init];
		[self _initConnection];
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[m_sourceFiles release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setBreakpointAtFileWithId:(uint32_t)fileId line:(uint32_t)line
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSetBreakpoints];
	[msg encodeUnsignedInt:1];
	[msg encodeUnsignedInt:((line << 16) | fileId)];
	[self _sendMessage:msg];
}

- (void)resume
{
	[self _sendMessage:[FDBMessage messageWithType:kFDBOutMessageTypeContinue]];
}

- (void)stepContinue
{
	[self _sendMessage:[FDBMessage messageWithType:kFDBOutMessageTypeStepContinue]];
}

- (void)requestSWF:(uint16_t)index
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeGetSWF];
	[msg encodeUnsignedShort:index];
	[self _sendMessage:msg];
}

- (void)requestSWFInfo:(uint16_t)swfIndex
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSWFInfo];
	[msg encodeUnsignedShort:swfIndex];
	[msg encodeUnsignedShort:0];
	[self _sendMessage:msg];
}



#pragma mark -
#pragma mark Private methods

- (void)_initConnection
{
	NSLog(@"init connection");
	[self _continueReading];
	[self _sendOptionMessage:@"disable_script_stuck_dialog" value:@"on"];
	[self _sendOptionMessage:@"disable_script_stuck" value:@"on"];
	[self _sendOptionMessage:@"break_on_fault" value:@"on"];
	[self _sendOptionMessage:@"enumerate_override" value:@"on"];
	[self _sendOptionMessage:@"notify_on_failure" value:@"on"];
	[self _sendOptionMessage:@"invoke_setters" value:@"on"];
	[self _sendOptionMessage:@"swf_load_messages" value:@"on"];
	[self _sendOptionMessage:@"getter_timeout" value:kFDBPrefGetVarResponseTimeout];
	[self _sendOptionMessage:@"setter_timeout" value:kFDBPrefSetVarResponseTimeout];
	[self _sendSquelch:YES];
	[self requestSWFInfo:0];
	[self requestSWF:0];
}

- (void)_sendMessage:(FDBMessage *)msg
{
//	NSLog(@"send: %@", [msg messageData]);
	[m_socket writeData:[msg messageData] withTimeout:-1 tag:0];
}

- (void)_sendOptionMessage:(NSString *)option value:(NSString *)value
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSetOption];
	[msg encodeUTF:option];
	[msg encodeUTF:value];
	[self _sendMessage:msg];
}

- (void)_sendSquelch:(BOOL)bFlag
{
	FDBMessage *msg = [FDBMessage messageWithType:kFDBOutMessageTypeSetSquelch];
	[msg encodeUnsignedInt:(bFlag ? 0 : 1)];
}

- (void)_continueReading
{
	[m_socket readDataToLength:8 withTimeout:-1 tag:kReadDataLengthTag];
}

- (void)_handleMessage:(FDBMessage *)msg
{
	switch (msg.type)
	{
		case kFDBInMessageTypeParam:
		{
			NSString *name = [msg decodeUTF];
			NSString *value = [msg decodeUTF];
			NSLog(@"%@: %@", name, value);
			break;
		}
		case kFDBInMessageTypeScript:
		{
			uint32_t module = [msg decodeUnsignedInt];
			uint32_t bitmap = [msg decodeUnsignedInt];
			NSString *name = [msg decodeUTF];
			NSString *text = [msg decodeUTF];
			int32_t swfIndex = [msg bytesAvailable] >= 4 ? [msg decodeUnsignedInt] : -1;
			[self _addSourceModule:[FDBSourceModule moduleWithSWFIndex:swfIndex module:module 
																bitmap:bitmap name:name text:text]];
			break;
		}
		case kFDBInMessageTypeSetBreakpoint:
		{
			uint32_t count = [msg decodeUnsignedInt];
			NSLog(@"num breakpoints: %d", count);
			while (count-- > 0)
			{
				uint32_t bp = [msg decodeUnsignedInt];
				uint32_t file = bp & 0xffff;
				uint32_t line = bp >> 16 & 0xffff;
				NSLog(@"set breakpoint at file: %d, line: %d", file, line);
			}
			break;
		}
		case kFDBInMessageTypeAskBreakpoints:
		{
			NSLog(@"ask breakpoints");
			//[self setBreakpointAtFileWithId:19 line:1745];
			break;
		}
		case kFDBInMessageTypeBreakAt:
		{
			uint32_t bp = [msg decodeUnsignedInt];
			uint32_t ptr = [msg decodeUnsignedInt]; // @todo get pointer (32 vs 64 bit, depending on player)
			NSString *stack = [msg decodeUTF];
			
			uint32_t file = bp & 0xffff;
			uint32_t line = bp >> 16 & 0xffff;
			NSLog(@"break at file: %d line: %d stack: %@ ptr: %d", file, line, stack, ptr);
			break;
		}
		case kFDBInMessageTypeBreakAtExt:
		{
			uint32_t bp = [msg decodeUnsignedInt];
			uint32_t num = [msg decodeUnsignedInt];
			
			while (num-- > 0)
			{
				uint32_t bpi = [msg decodeUnsignedInt];
				uint32_t ptr = [msg decodeUnsignedInt];
				NSString *stack = [msg decodeUTF];
				uint32_t file = bp & 0xffff;
				uint32_t line = bp >> 16 & 0xffff;
				NSLog(@"bpi: %d ptr: %d stack: %@ file: %d line: %d", bpi, ptr, stack, file, line);
			}
			break;
		}
		case kFDBInMessageTypeVersion:
		{
			m_playerVersion = [msg decodeUnsignedInt];
			NSLog(@"player version: %d", m_playerVersion);
			uint32_t pointerSize = [msg bytesAvailable] >= 1 ? [msg decodeChar] : 4;
			NSLog(@"pointer size: %d", pointerSize);
			break;
		}
		case kFDBInMessageTypeNumScript:
		{
			uint32_t num = [msg decodeUnsignedInt];
			NSLog(@"num files: %d", num);
			if ([msg bytesAvailable] >= 4)
			{
				uint32_t swfIndex = [msg decodeUnsignedInt];
				NSLog(@"swf index: %d", swfIndex);
			}
			break;
		}
		case kFDBInMessageTypeOption:
		{
			NSString *name = [msg decodeUTF];
			NSString *value = [msg decodeUTF];
			NSLog(@"option name: %@ value: %@", name, value);
			break;
		}
		case kFDBInMessageTypeContinue:
		{
			NSLog(@"continue");
			break;
		}
		case kFDBInMessageTypeSetLocalVariables:
		{
			uint32_t ptr = [msg decodeUnsignedInt];
			NSLog(@"set local var %d", ptr);
			break;
		}
		case kFDBInMessageTypeNewObject:
		{
			//uint32_t ptr = [msg decodeUnsignedInt];
			//NSLog(@"new object %d", ptr);
			break;
		}
		case kFDBInMessageTypeSetMenuState:
		{
			NSLog(@"set menu state");
			NSLog(@"%@", [msg plainData]);
			break;
		}
		case kFDBInMessageTypeDeleteVariable:
		{
			uint32_t ptr = [msg decodeUnsignedInt];
			NSString *name = [msg decodeUTF];
			NSLog(@"delete %@ (%d)", name, ptr);
			break;
		}
		case kFDBInMessageTypeSetVariable2:
		{
			//NSLog(@"set variable2");
			break;
		}
		case kFDBInMessageTypeProcessTag:
		{
			NSLog(@"process tag");
			// need to send a response to this message to keep the player going
			[self _sendMessage:[FDBMessage messageWithType:kFDBOutMessageTypeProcessedTag]];
			break;
		}
		case kFDBInMessageTypeErrorURLOpen:
		{
			NSString *url = [msg decodeUTF];
			NSLog(@"could not open url %@", url);
			break;
		}
		case kFDBInMessageTypeSetVariable:
		{
			uint32_t ptr = [msg decodeUnsignedInt];
			NSString *name = [msg decodeUTF];
			uint32_t type = [msg decodeUnsignedShort];
			uint32_t flags = [msg decodeUnsignedInt];
			NSString *value = [msg decodeUTF];
			NSLog(@"set variable (%d) type: %d flags: %d name: %@ value: %@", ptr, type, flags, 
				  name, value);
			break;
		}
		case kFDBInMessageTypeExit:
		{
			NSLog(@"disconnect");
			break;
		}
		case kFDBInMessageTypeSWFInfo:
		{
			uint16_t count = [msg decodeUnsignedShort];
			for (uint16_t i = 0; i < count; i++)
			{
				uint32_t index = [msg decodeUnsignedInt];
				uint32_t ptr = [msg decodeUnsignedInt];
				
				if (ptr == 0)
				{
					NSLog(@"unloaded");
					return;
				}
				
				BOOL debugComing = [msg decodeChar] == 0 ? NO : YES;
				uint8_t vmVersion = [msg decodeChar];
				[msg decodeUnsignedShort]; // reserved
				uint32_t swfSize = [msg decodeUnsignedInt];
				uint32_t swdSize = [msg decodeUnsignedInt];
				uint32_t scriptCount = [msg decodeUnsignedInt];
				uint32_t offsetCount = [msg decodeUnsignedInt];
				uint32_t breakpointCount = [msg decodeUnsignedInt];
				
				uint32_t port = [msg decodeUnsignedInt];
				NSString *path = [msg decodeUTF];
				NSString *url = [msg decodeUTF];
				NSString *host = [msg decodeUTF];
				
				uint32_t num = [msg decodeUnsignedInt];
				for (uint32_t j = 0; j < num; j++)
				{
					uint32_t local = [msg decodeUnsignedInt];
					uint32_t global = [msg decodeUnsignedInt];
					NSLog(@"local %d - global %d", local, global);
				}
				
				NSLog(@"vmVersion: %d\nswfSize: %d\nswdSize: %d\nscriptCount: %d\noffsetCount: %d\nbreakpointCount: %d\nport: %d\npath: %@\nurl: %@\nhost: %@", 
					  vmVersion, swfSize, swdSize, scriptCount, offsetCount, breakpointCount, port, path, url, host);
			}
			[self _sendMessage:[FDBMessage messageWithType:kFDBOutMessageTypePassAllExceptionsToDebugger]];
			[self resume];
			break;
		}
		case kFDBInMessageTypeGetSWF:
		{
			NSLog(@"received swf");
			break;
		}
		default:
			NSLog(@"Unknown message type %d", msg.type);
	}
}

- (void)_addSourceModule:(FDBSourceModule *)module
{
	[m_sourceFiles addObject:module];
}



#pragma mark -
#pragma mark AsyncSocket Delegate methods

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (tag == kReadDataLengthTag)
	{
		uint32_t pos = 0;
		const uint8_t *bytes = [data bytes];
		uint8_t ch1 = bytes[pos++];
		uint8_t ch2 = bytes[pos++];
		uint8_t ch3 = bytes[pos++];
		uint8_t ch4 = bytes[pos++];
		uint32_t len = CFSwapInt32BigToHost(((ch1 << 24) & 0xff000000) + ((ch2 << 16) & 0xff0000) + 
			((ch3 << 8) & 0xff00) + (ch4 & 0xff));
		
		ch1 = bytes[pos++];
		ch2 = bytes[pos++];
		ch3 = bytes[pos++];
		ch4 = bytes[pos++];
		uint32_t cmd = CFSwapInt32BigToHost(((ch1 << 24) & 0xff000000) + ((ch2 << 16) & 0xff0000) + 
			((ch3 << 8) & 0xff00) + (ch4 & 0xff));

		//NSLog(@"type: %d len: %d", cmd, len);
		m_lastMessageType = cmd;

		if (len > 0)
		{
			[sock readDataToLength:len withTimeout:-1 tag:kReadDataTag];
			return;
		}
		else
		{
			FDBMessage *msg = [FDBMessage messageWithType:cmd];
			[self _handleMessage:msg];
			m_lastMessageType = kFDBInMessageTypeUnknown;
		}
	}
	else if (tag == kReadDataTag)
	{
		FDBMessage *msg = [FDBMessage messageWithType:m_lastMessageType data:data];
		[self _handleMessage:msg];
		m_lastMessageType = kFDBInMessageTypeUnknown;
	}
	[self _continueReading];
}

@end