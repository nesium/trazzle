/*
 *  Model.h
 *  test
 *
 *  Created by Marc Bauer on 07.11.08.
 *  Copyright 2008 nesiumdotcom. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

@interface Model : NSObject
{
	NSMutableDictionary *m_data;
	NSDictionary *m_compilerSettingsConfig;
}

- (id) initWithCompilerSettingsConfig: (NSArray *) config;
- (void) setValue: (id) value atIndex: (unsigned int) index;
- (NSString *) compilerString;
@end