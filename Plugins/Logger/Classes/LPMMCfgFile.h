//
//  LPMMCfgFile.h
//  Logger
//
//  Created by Marc Bauer on 12.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kMMCfgGlobalPath;
extern NSString *const kMMCfgLocalPath;

@interface LPMMCfgFile : NSObject{
@private
	NSMutableDictionary *m_settings;
}
- (id)initWithContentsOfFile:(NSString *)aPath error:(NSError **)error;
+ (id)mmCfg;
+ (id)mmCfgWithContentsOfFile:(NSString *)aPath error:(NSError **)error;
- (BOOL)writeToFile:(NSString *)aPath atomically:(BOOL)atomically error:(NSError **)error;
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
@end