//
//  FDBMessage.h
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDB.h"

@interface FDBMessage : NSObject
{
	uint32_t m_type;
	NSMutableData *m_data;
	uint32_t m_position;
	uint8_t *m_bytes;
}
@property (nonatomic, assign) uint32_t type;

+ (FDBMessage *)messageWithType:(int32_t)type;
- (uint32_t)size;
- (NSData *)plainData;
- (NSData *)messageData;

- (void)encodeChar:(uint8_t)value;
- (void)encodeDataObject:(NSData *)data;
- (void)encodeInt:(int32_t)value;
- (void)encodeShort:(int16_t)value;
- (void)encodeUnsignedInt:(uint32_t)value;
- (void)encodeUnsignedShort:(uint16_t)value;
- (void)encodeUTF:(NSString *)value;
@end
