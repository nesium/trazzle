//
//  LPExistingFilesCache.h
//  Logger
//
//  Created by Marc Bauer on 28.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LPExistingFilesCache : NSObject
{
	NSMutableDictionary *m_filesCache;
}
+ (LPExistingFilesCache *)sharedCache;
- (BOOL)fileExistsAtPath:(NSString *)path;
@end