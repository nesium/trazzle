#import "FMTFileChooserCell.h"


@interface FMTFileChooserCell (Private)
- (NSRect) buttonCellFrameForBounds: (NSRect) bounds;
- (NSRect) textfieldCellFrameForBounds: (NSRect) bounds;
@end


@implementation FMTFileChooserCell

- (id) init
{
	self = [super init];
	m_button = [[NSButtonCell alloc] init];
	[m_button setTitle: @""];
	[m_button setBordered: NO];
	NSImage *icon = [[NSImage alloc] initWithContentsOfFile: [[NSBundle bundleForClass: [self class]] 
			pathForImageResource: @"browseButton.png"]];
	[m_button setImage:icon];
	[icon release];
	return self;
}

- (id) copyWithZone: (NSZone *) zone
{
	FMTFileChooserCell *copy = [[FMTFileChooserCell alloc] init];
	[copy setObjectValue: [self objectValue]];
	[copy setFont: [self font]];
	[copy setTarget: [self target]];
	[copy setAction: [self action]];
	[copy setEditable: [self isEditable]];
	[copy setLineBreakMode: [self lineBreakMode]];
	return copy;
}

- (void) dealloc
{
	[m_button release];
	[super dealloc];
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{	
	NSRect square = [self buttonCellFrameForBounds: cellFrame];
	[m_button drawWithFrame: square inView: controlView];
	[super drawWithFrame: [self textfieldCellFrameForBounds: cellFrame] inView: controlView];
}

- (void) selectWithFrame: (NSRect) aRect inView: (NSView *) controlView editor: (NSText *) textObj 
	delegate: (id) anObject start: (int) selStart length: (int) selLength
{
	[super selectWithFrame: [self textfieldCellFrameForBounds: aRect] inView: controlView editor: textObj 
		delegate: anObject start: selStart length: selLength];		
}

- (void) editWithFrame: (NSRect) aRect inView: (NSView *) controlView editor: (NSText *) textObj 
	delegate: (id) anObject event: (NSEvent *) theEvent
{
	[super editWithFrame: [self textfieldCellFrameForBounds: aRect] inView: controlView editor: textObj 
		delegate: anObject event: theEvent];
}


- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView 
	untilMouseUp:(BOOL)flag
{
	NSRect swatchBounds = [self buttonCellFrameForBounds: cellFrame];
	NSPoint locationInCell = [controlView convertPoint: [theEvent locationInWindow] 
		fromView: nil];

	if(NSPointInRect(locationInCell, swatchBounds))
	{
		[m_button highlight: YES withFrame: swatchBounds inView: controlView];		
		return [m_button trackMouse: theEvent inRect: swatchBounds 
			ofView: controlView untilMouseUp: flag];
	}
    return [super trackMouse: theEvent inRect: cellFrame 
		ofView: controlView untilMouseUp:flag];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	return NSCellHitContentArea | NSCellHitEditableTextArea | NSCellHitTrackableArea;
}

- (NSRect) buttonCellFrameForBounds: (NSRect) bounds
{
	NSRect square = bounds;
	if (square.size.height < square.size.width)
	{
		square.size.width = square.size.height;
	} 
	else 
	{
		square.size.height = square.size.width;
	}
	square.origin.x = bounds.origin.x + bounds.size.width - square.size.width - 1;
	square = NSInsetRect(square, 1, 1);
	return square;
}

- (NSRect) textfieldCellFrameForBounds: (NSRect) bounds
{
	NSRect square = [self buttonCellFrameForBounds: bounds];
	NSRect rect = bounds;
	rect.size.width -= (square.size.width + 7.0);
	return rect;	
}

- (void) setTarget: (id) target
{
	[m_button setTarget: target];
	[super setTarget: target];
}

- (void) setAction: (SEL) selector
{
	[m_button setAction: selector];
	[super setAction: selector];
}


@end
