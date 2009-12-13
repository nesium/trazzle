//
//  FileMonitor.h
//  Trazzle
//
//  Created by Marc Bauer on 10.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKKQueue.h"

@class FileMonitor;

@protocol FileObserver
- (void)fileMonitor:(FileMonitor *)fm fileDidChangeAtPath:(NSString *)path;
@end


@interface FileMonitor : NSObject{
	NSMutableDictionary *m_observers;
}
+ (FileMonitor *)sharedMonitor;
- (void)addObserver:(id <FileObserver>)observer forFileAtPath:(NSString *)path;
- (void)removeObserver:(id <FileObserver>)observer forFileAtPath:(NSString *)path;
- (void)removeObserver:(id <FileObserver>)observer;
@end