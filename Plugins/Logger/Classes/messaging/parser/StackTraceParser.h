//
//  StackTraceParser.h
//  Trazzle
//
//  Created by Marc Bauer on 29.02.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StackTraceItem.h"


@interface StackTraceParser : NSObject 
{

}

+ (NSArray *)parseStackTrace:(NSString *)stacktrace ofLanguageType:(NSString *)language;
+ (NSArray *)parseAS3StackTrace:(NSString *)stacktrace;

@end