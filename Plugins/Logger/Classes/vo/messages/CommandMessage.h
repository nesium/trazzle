//
//  CommandMessage.h
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _CommandActionType
{
	kCommandActionTypeUnknown,
	kCommandActionTypeClear,
	kCommandActionTypeStartFileMonitoring,
	kCommandActionTypeStopFileMonitoring
} CommandActionType;


@interface CommandMessage : NSObject 
{
	CommandActionType m_type;
	NSDictionary *m_attributes;
}

@property (nonatomic, assign) CommandActionType type;
@property (nonatomic, retain) NSDictionary *attributes;

- (id)initWithAction:(NSString *)action attributes:(NSDictionary *)attributes;

@end