//
//  ZZTabBarControl.m
//  Trazzle
//
//  Created by Marc Bauer on 23.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZTabBarControl.h"

@interface NSObject (PSMTabBarController)
- (NSRect)cellFrameAtIndex:(int)i;
@end

@interface ZZTabBarControl (Private)
- (void)_startDraggingWindow:(NSEvent *)theEvent;
@end


@implementation ZZTabBarControl

- (void)mouseDown:(NSEvent*)theEvent
{
	[NSApp activateIgnoringOtherApps:YES];

	NSPoint where = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:where fromView:nil];
	BOOL shouldDrag = YES;
	
	for (int i = 0; i < [_cells count]; i++)
	{
		if (NSPointInRect(localPoint, [_controller cellFrameAtIndex:i]))
		{
			shouldDrag = NO;
			break;
		}
	}
	
	if (![_overflowPopUpButton isHidden] && NSPointInRect(localPoint, [_overflowPopUpButton frame]))
		shouldDrag = NO;

	if (shouldDrag)	
		[self performSelector:@selector(_startDraggingWindow:) withObject:theEvent afterDelay:0.0];
	else
		[super mouseDown:theEvent];
}

- (void)_startDraggingWindow:(NSEvent *)theEvent
{
	NSWindow *window = [self window];	
	NSPoint where = [theEvent locationInWindow];
	where = [window convertBaseToScreen:where];
	NSPoint origin = [window frame].origin;
	uint16_t mask = NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask;
	// Now we loop handling mouse events until we get a mouse up event.
	while ((theEvent = [NSApp nextEventMatchingMask:mask untilDate:[NSDate distantFuture] 
		inMode:NSEventTrackingRunLoopMode dequeue:YES]) && ([theEvent type] != NSLeftMouseUp))
	{
		// Set up a local autorelease pool for the loop to prevent buildup of temporary objects.
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSPoint now = [window convertBaseToScreen:[theEvent locationInWindow]];
		origin.x += now.x - where.x;
		origin.y += now.y-where.y;
		// Move the window by the mouse displacement since the last event.
		[window setFrameOrigin:origin];
		where = now;
		[pool release];
	}
}

@end