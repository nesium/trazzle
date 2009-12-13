//
//  StackTraceItem.h
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractMessage.h"


@interface StackTraceItem : AbstractMessage{
	NSString *fullClassName;
	NSString *shortClassName;
	NSString *method;
	NSString *file;
	int32_t line;
}
@property (nonatomic, retain) NSString *fullClassName;
@property (nonatomic, readonly) NSString *shortClassName;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, assign) int32_t line;
@end