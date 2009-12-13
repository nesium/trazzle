//
//  LPTailTask.h
//  Logger
//
//  Created by Marc Bauer on 13.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LPTailTask : NSObject{
@private
	NSString *m_path;
	NSTask *m_task;
	NSPipe *m_pipe;
	NSMutableString *m_buffer;
	id m_delegate;
}
- (id)initWithFile:(NSString *)aPath delegate:(id)aDelegate;
- (void)launch;
- (void)terminate;
@end

@interface NSObject (LPTailTaskDelegate)
- (void)tailTask:(LPTailTask *)task didReceiveLine:(NSString *)line;
@end