//
//  CommandMessage.h
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractMessage.h"

typedef enum _CommandActionType{
	kCommandActionTypeUnknown,
	kCommandActionTypeClear,
	kCommandActionTypeStartFileMonitoring,
	kCommandActionTypeStopFileMonitoring,
	kCommandActionTypeUpdateStatusBar
} CommandActionType;


@interface CommandMessage : AbstractMessage{
	CommandActionType type;
	NSDictionary *attributes;
	NSObject *data;
}

@property (nonatomic, assign) CommandActionType type;
@property (nonatomic, retain) NSDictionary *attributes;
@property (nonatomic, retain) NSObject *data;

- (id)initWithAction:(NSString *)action attributes:(NSDictionary *)attributes;
@end