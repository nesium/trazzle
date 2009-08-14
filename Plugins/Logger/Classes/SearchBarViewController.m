//
//  SearchBarViewController.m
//  Logger
//
//  Created by Marc Bauer on 13.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "SearchBarViewController.h"


@implementation SearchBarViewController

@end



@implementation SearchBarView

- (void)drawRect:(NSRect)dirtyRect
{
	NSImage *pattern = [[NSImage alloc] initWithContentsOfFile:
		[[NSBundle bundleForClass:[self class]] pathForResource:@"SearchBarPattern" ofType:@"png"]];
	NSRect imageRect = (NSRect){0, 0, [pattern size].width, [pattern size].height};
	while (imageRect.origin.x < [self bounds].size.width)
	{
		[pattern drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver 
				   fraction:1.0];
		imageRect.origin.x += imageRect.size.width;
	}
	[pattern release];
}
@end


@interface NSCell (SearchBarDoneButtonCellPrivate)
- (NSDictionary *)_textAttributes;
@end

@implementation SearchBarDoneButtonCell

- (void)drawBezelWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.size.height = 19.0;
	
	NSString *imageName = [self isHighlighted] 
		? @"SearchBarDoneButtonDown" 
		: @"SearchBarDoneButtonUp";
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:
		[[NSBundle bundleForClass:[self class]] pathForResource:imageName ofType:@"png"]];
	[image setFlipped:YES];
	[image drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[image release];
}

- (NSDictionary *)_textAttributes
{
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
	[attributes addEntriesFromDictionary:[super _textAttributes]];
	[attributes setObject:[NSFont boldSystemFontOfSize:10] forKey:NSFontAttributeName];
	[attributes setObject:[NSColor colorWithCalibratedWhite:0.408 alpha:1.000] 
				   forKey:NSForegroundColorAttributeName];
	return attributes;
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
	frame.origin.y -= 5;	
	return [super drawTitle:title withFrame:frame inView:controlView];
}
@end



@implementation SearchBarSearchFieldFieldEditor

- (NSDictionary *)selectedTextAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor colorWithCalibratedWhite:0.2 alpha:1.000], NSBackgroundColorAttributeName, 
			[NSColor whiteColor], NSForegroundColorAttributeName, 
			nil];
}

- (void)keyDown:(NSEvent *)event
{
	if ([event keyCode] == 53) // escape
	{
		// @FIXME change that probably most ugly way of preventing the searchfield from 
		// deleting it's contents when pressing escape
		[[[[self nextResponder] nextResponder] nextResponder] keyDown:event];
		return;
	}
	[super keyDown:event];
}

@end




@implementation SearchBarSearchField

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder:coder])
	{
		m_fieldEditor = nil;
		NSRect frame = [self frame];
		frame.size.height = 21.0;
		[self setFrame:frame];
	}
	return self;
}

- (id)_customFieldEditorForWindow:(NSWindow *)window
{
	if (!m_fieldEditor)
	{
		m_fieldEditor = [[SearchBarSearchFieldFieldEditor alloc] init];
		[m_fieldEditor setInsertionPointColor:[NSColor colorWithCalibratedWhite:0.7 alpha:1.000]];
		[m_fieldEditor setFieldEditor:YES];
		
		NSMutableDictionary *attributes = [[m_fieldEditor selectedTextAttributes] mutableCopy];
		[attributes setObject:[NSColor redColor] forKey:NSBackgroundColorAttributeName];
		[m_fieldEditor setSelectedTextAttributes:attributes];
		[attributes release];
	}
	return m_fieldEditor;
}

@end




@implementation SearchBarSearchFieldCell

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder:coder])
	{
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle bundleForClass:[self class]] 
				pathForResource:@"SearchBarSearchFieldDeleteButton" ofType:@"png"]];
		NSImage *altImage = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle bundleForClass:[self class]]
				pathForResource:@"SearchBarSearchFieldDeleteButtonAlternate" ofType:@"png"]];
		NSButtonCell *cancelButtonCell = [self cancelButtonCell];
		NSLog(@"shortcut: %@", [cancelButtonCell keyEquivalent]);
		
		[cancelButtonCell setImage:image];
		[cancelButtonCell setAlternateImage:altImage];
		
		[self setSearchButtonCell:nil];
		[self setCancelButtonCell:cancelButtonCell];
		[image release];
		[altImage release];
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.size.height = 21.0;
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] 
		pathForResource:@"SearchBarSearchFieldBackground" ofType:@"png"]];
	[image setFlipped:YES];
	[image drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[image release];
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSDictionary *)_textAttributes
{
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
	[attributes addEntriesFromDictionary:[super _textAttributes]];
	[attributes setObject:[NSFont systemFontOfSize:10] forKey:NSFontAttributeName];
	[attributes setObject:[NSColor colorWithCalibratedWhite:0.408 alpha:1.000] 
				   forKey:NSForegroundColorAttributeName];
	return attributes;
}

@end