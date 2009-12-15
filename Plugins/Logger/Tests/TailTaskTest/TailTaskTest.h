//
//  TailTaskTest.h
//  Logger
//
//  Created by Marc Bauer on 13.12.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "LPTailTask.h"


@interface TailTaskTest : GHAsyncTestCase{
	LPTailTask *m_tailTask;
	NSMutableArray *m_receivedLines;
	NSMutableArray *m_sentLines;
	NSFileHandle *m_fileHandle;
}
@end