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

- (NSData *)plainData
{
	return m_data;
}

- (NSData *)messageData
{
	uint32_t cmd = CFSwapInt32HostToBig(m_type);
	uint32_t size = CFSwapInt32HostToBig([m_data length]);
	NSMutableData *data = [NSMutableData data];
	[self _appendBytes:&cmd length:sizeof(uint32_t) toData:data atPosition:0];
	[self _appendBytes:&size length:sizeof(uint32_t) toData:data atPosition:4];
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
	NSLog(@"encode utf: %@", value);
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self encodeDataObject:data];
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
	[self _ensureLength:length];
	[self _appendBytes:bytes length:length toData:m_data atPosition:m_position];
	m_position += length;
}

- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length toData:(NSMutableData *)data 
		  atPosition:(uint32_t)position
{
	uint8_t *mutBytes = [data mutableBytes];
	uint8_t *chars = (uint8_t *)bytes;
	for (NSUInteger i = 0; i < length; i++)
		mutBytes[position++] = chars[i];
}

@end