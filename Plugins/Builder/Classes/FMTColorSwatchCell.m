#import "FMTColorCell.h"


@implementation FMTColorSwatchCell

- (id) init
{
	self = [super init];
	[self setBezelStyle: NSShadowlessSquareBezelStyle];
	[self setTitle: @""];
	[self setButtonType: NSMomentaryLightButton];
	return self;
}

- (void) dealloc
{
	[m_hexColor release];
	[super dealloc];
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
	[super drawWithFrame: cellFrame	inView: controlView];
	[[NSColor ColorFromHexRepresentation: [self objectValue]] 
		drawSwatchInRect: NSInsetRect(cellFrame, 3, 3)];	
}

- (void) setObjectValue: (id) anObject
{
	[m_hexColor release];
	m_hexColor = [anObject retain];
}

- (id) objectValue
{
	return m_hexColor;
}

@end