//
//  AbstractMessage.h
//  Logger
//
//  Created by Marc Bauer on 31.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"

typedef enum _LPMessageType
{
	kLPMessageTypeSystem = 0,
	kLPMessageTypeFlashLog = 1,
	kLPMessageTypeCommand = 2,
	kLPMessageTypeSocket = 3,
	kLPMessageTypePolicyRequest = 4,
	kLPMessageTypeStackTrace = 5,
	kLPMessageTypeConnectionSignature = 6
} LPMessageType;

@interface AbstractMessage : NSObject
{
	uint32_t index;
	NSString *message;
	NSTimeInterval timestamp;
	LPMessageType messageType;
	
}
@property (nonatomic, assign) uint32_t index;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) LPMessageType messageType;

+ (AbstractMessage *)messageWithType:(LPMessageType)type;
+ (AbstractMessage *)messageWithType:(LPMessageType)type message:(NSString *)message;
+ (BOOL)isKeyExcludedFromWebScript:(const char *)name;
@end