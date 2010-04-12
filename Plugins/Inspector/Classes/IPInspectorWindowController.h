//
//  IPInspectorWindowController.h
//  Inspector
//
//  Created by Marc Bauer on 10.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAMF/CocoaAMF.h>
#import "IPWarpWindow.h"

@class IPObjectWrapper;

@interface IPInspectorWindowController : NSWindowController{
	IBOutlet NSTextView *m_textView;
	IBOutlet NSOutlineView *m_outlineView;
	IPObjectWrapper *m_rootObject;
	NSPoint m_warpOrigin;
}
- (void)displayObject:(id)object warpOrigin:(NSPoint)warpOrigin;
@end



@interface IPObjectWrapper : NSObject{
	NSArray *m_children;
	NSString *m_objectClassName;
	NSString *m_name;
	NSString *m_value;
}
@property (retain) NSString *name;
@property (readonly) NSString *objectClassName;
@property (readonly) NSArray *children;
@property (readonly) NSString *value;
- (BOOL)hasChildren;
@end