//
//  FDBSourceModule.h
//  Logger
//
//  Created by Marc Bauer on 18.07.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FDBSourceModule : NSObject
{
	int32_t m_swfIndex;
	uint32_t m_bitmap;
	uint32_t m_module;
	NSString *m_package;
	NSString *m_path;
	NSString *m_text;
}
@property (nonatomic, readonly) uint32_t index;
+ (FDBSourceModule *)moduleWithSWFIndex:(int32_t)swfIndex module:(uint32_t)module 
								 bitmap:(uint32_t)bitmap name:(NSString *)name text:(NSString *)text;
- (id)initWithSWFIndex:(int32_t)swfIndex module:(uint32_t)module bitmap:(uint32_t)bitmap
				  name:(NSString *)name text:(NSString *)text;
@end