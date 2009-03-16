#import "FMTColorCell.h"


@interface FMTColorCell (Private)
- (NSRect) colorSwatchCellFrameForBounds: (NSRect) bounds;
- (NSRect) textfieldCellFrameForBounds: (NSRect) bounds;
@end



@implementation FMTColorCell

- (id) init
{
	self = [super init];
	m_swatchCell = [[FMTColorSwatchCell alloc] init];
	return self;
}

- (id) copyWithZone: (NSZone *) zone
{
	FMTColorCell *copy = [[FMTColorCell alloc] init];
	[copy setObjectValue: [self objectValue]];
	[copy setFont: [self font]];
	[copy setTarget: [self target]];
	[copy setAction: [self action]];
	[copy setEditable: [self isEditable]];
	return copy;
}

- (void) dealloc
{
	[m_swatchCell release];
	[super dealloc];
}

- (void) colorClick: (id) sender
{
	[self performClick: self];
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{	
	NSRect square = [self colorSwatchCellFrameForBounds: cellFrame];
	
	[self setTextColor: [NSColor ColorFromHexRepresentation: @"#999999"]];
	
	[m_swatchCell drawWithFrame: square inView: controlView];
	[super drawWithFrame: [self textfieldCellFrameForBounds: cellFrame] inView: controlView];
}

- (void) selectWithFrame: (NSRect) aRect inView: (NSView *) controlView editor: (NSText *) textObj 
	delegate: (id) anObject start: (int) selStart length: (int) selLength
{
	[self setTextColor: [NSColor ColorFromHexRepresentation: @"#000000"]];
	[super selectWithFrame: [self textfieldCellFrameForBounds: aRect] inView: controlView editor: textObj 
		delegate: anObject start: selStart length: selLength];		
}

- (void) editWithFrame: (NSRect) aRect inView: (NSView *) controlView editor: (NSText *) textObj 
	delegate: (id) anObject event: (NSEvent *) theEvent
{
	[self setTextColor: [NSColor ColorFromHexRepresentation: @"#000000"]];
	[super editWithFrame: [self textfieldCellFrameForBounds: aRect] inView: controlView editor: textObj 
		delegate: anObject event: theEvent];
}

- (void) setObjectValue: (id) anObject
{
	[m_swatchCell setObjectValue: anObject];
	[super setObjectValue: anObject];
}

- (BOOL) trackMouse: (NSEvent *) theEvent inRect: (NSRect) cellFrame  
	ofView: (NSView *) controlView untilMouseUp: (BOOL) flag
{
	NSRect swatchBounds = [self colorSwatchCellFrameForBounds: cellFrame];
	NSPoint locationInCell = [controlView convertPoint: [theEvent locationInWindow] 
		fromView: nil];

	if(NSPointInRect(locationInCell, swatchBounds))
	{
		[m_swatchCell highlight: YES withFrame: swatchBounds inView: controlView];		
		return [m_swatchCell trackMouse: theEvent inRect: swatchBounds 
			ofView: controlView untilMouseUp: flag];
	}
    return [super trackMouse: theEvent inRect: cellFrame 
		ofView: controlView untilMouseUp:flag];
}

- (NSRect) colorSwatchCellFrameForBounds: (NSRect) bounds
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
	square.origin.x += 1.0;
	square = NSInsetRect(square, 1, 1);
	return square;
}

- (NSRect) textfieldCellFrameForBounds: (NSRect) bounds
{
	NSRect square = [self colorSwatchCellFrameForBounds: bounds];
	NSRect rect = bounds;
	rect.size.width -= (square.size.width + 7.0);
	rect.origin.x += square.size.width + 7.0;
	return rect;	
}

- (void) setTarget: (id) target
{
	[m_swatchCell setTarget: target];
	[super setTarget: target];
}

- (void) setAction: (SEL) selector
{
	[m_swatchCell setAction: selector];
	[super setAction: selector];
}

@end