//
//  FDBMessage.m
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "FDBMessage.h"


@interface FDBMessage (Private)
- (void)_ensureLength:(unsigned)length;
- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length;
- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length toData:(NSMutableData *)data 
		  atPosition:(uint32_t)position;
@end


@implementation FDBMessage

@synthesize type=m_type;

#pragma mark -
#pragma mark Initialization & Deallocation

+ (FDBMessage *)messageWithType:(int32_t)type
{
	FDBMessage *msg = [[[FDBMessage alloc] init] autorelease];
	msg.type = type;
	return msg;
}

+ (FDBMessage *)messageWithType:(int32_t)type data:(NSData *)data
{
	FDBMessage *msg = [[[FDBMessage alloc] initWithData:data] autorelease];
	msg.type = type;
	return msg;
}

- (id)init
{
	if (self = [super init])
	{
		m_data = [[NSMutableData alloc] init];
		m_position = 0;
		m_bytes = [m_data mutableBytes];
	}
	return self;
}

- (id)initWithData:(NSData *)data
{
	if (self = [super init])
	{
		m_data = [data mutableCopy];
		m_position = 0;
		m_bytes = [m_data mutableBytes];
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (uint32_t)size
{
	return [m_data length];
}

- (uint32_t)bytesAvailable
{
	return [m_data length] - m_position;
}

- (NSData *)plainData
{
	return m_data;
}

- (NSData *)messageData
{
	uint32_t cmd = CFSwapInt32HostToLittle(m_type);
	uint32_t size = CFSwapInt32HostToLittle([m_data length]);
	NSMutableData *data = [NSMutableData data];
	[self _appendBytes:&size length:sizeof(uint32_t) toData:data atPosition:0];
	[self _appendBytes:&cmd length:sizeof(uint32_t) toData:data atPosition:4];
	if ([m_data length]) [data appendData:m_data];
	return data;
}

- (void)encodeChar:(uint8_t)value
{
	[self _ensureLength:1];
	m_bytes[m_position++] = value;
}

- (void)encodeDataObject:(NSData *)data
{
	[m_data appendData:data];
	m_bytes = [m_data mutableBytes];
	m_position = [m_data length];
}

- (void)encodeInt:(int32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[self _appendBytes:&value length:sizeof(int32_t)];
}

- (void)encodeShort:(int16_t)value
{
	value = CFSwapInt16HostToBig(value);
	[self _appendBytes:&value length:sizeof(int16_t)];
}

- (void)encodeUnsignedInt:(uint32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[self _appendBytes:&value length:sizeof(uint32_t)];
}

- (void)encodeUnsignedShort:(uint16_t)value
{
	[self _ensureLength:2];
	m_bytes[m_position++] = (value >> 8) & 0xFF;
	m_bytes[m_position++] = value & 0xFF;
}

- (void)encodeUTF:(NSString *)value
{
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self encodeDataObject:data];
	[self encodeChar:'\0'];
}

- (NSString *)decodeUTF
{
	NSMutableData *strData = [NSMutableData data];
	uint8_t *chars;
	uint8_t c;
	uint32_t pos = 0;
	while (c = m_bytes[m_position++])
	{
		[strData setLength:[strData length] + 1];
		chars = [strData mutableBytes];
		chars[pos++] = c;
	}
	if ([strData length] == 0) return nil;
	[strData setLength:[strData length] + 1];
	chars[pos++] = '\0';	
	return [NSString stringWithUTF8String:(char *)chars];
}

- (uint32_t)decodeBytes:(uint8_t)len
{
	uint32_t value = 0;
	for (uint8_t i = 0; i < len; i++)
		value |= (m_bytes[m_position++] && 0xff) << (8 * i);
	return value;
}

- (uint8_t)decodeChar
{
	return m_bytes[m_position++];
}

- (uint32_t)decodeUnsignedInt
{
	uint8_t ch1 = m_bytes[m_position++];
	uint8_t ch2 = m_bytes[m_position++];
	uint8_t ch3 = m_bytes[m_position++];
	uint8_t ch4 = m_bytes[m_position++];
	return CFSwapInt32BigToHost(((ch1 << 24) & 0xff000000) + ((ch2 << 16) & 0xff0000) + 
								((ch3 << 8) & 0xff00) + (ch4 & 0xff));
}

- (uint16_t)decodeUnsignedShort
{
	uint8_t ch1 = m_bytes[m_position++];
	uint8_t ch2 = m_bytes[m_position++];
	return CFSwapInt16BigToHost(((ch1 << 8) & 0xff00) + (ch2 & 0xff));
}

#pragma mark -
#pragma mark Private methods

- (void)_ensureLength:(unsigned)length
{
	[m_data setLength:[m_data length] + length];
	m_bytes = [m_data mutableBytes];
}

- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length
{
	[self _appendBytes:bytes length:length toData:m_data atPosition:m_position];
	m_position += length;
}

- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length toData:(NSMutableData *)data 
		  atPosition:(uint32_t)position
{
	[data setLength:[data length] + length];
	uint8_t *chars = (uint8_t *)bytes;
	for (NSUInteger i = 0; i < length; i++)
	{
		uint8_t *mutBytes = [data mutableBytes];
		mutBytes[position++] = chars[i];
	}
}

@end