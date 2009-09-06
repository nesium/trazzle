//
//  PSMAdiumTabStyle.m
//  PSMTabBarControl
//
//  Created by Kent Sutherland on 5/26/06.
//  Copyright 2006 Kent Sutherland. All rights reserved.
//

#import "ZZTabStyle.h"
#import <PSMTabBarControl/PSMTabBarCell.h>
#import <PSMTabBarControl/PSMTabBarControl.h>

#define Adium_CellPadding 0
#define Adium_MARGIN_X 4
#define kPSMAdiumObjectCounterRadius 7.0
#define kPSMAdiumCounterMinWidth 20

#define kPSMTabBarControlSourceListHeight	28

#define kPSMTabBarLargeImageHeight			kPSMTabBarControlSourceListHeight - 4
#define kPSMTabBarLargeImageWidth			kPSMTabBarLargeImageHeight

@implementation ZZTabStyle

- (NSString *)name
{
    return @"Trazzle";
}

#pragma mark -
#pragma mark Creation/Destruction

- (id)init
{
    if ( (self = [super init]) ) {
		[self loadImages];
		_drawsUnified = NO;
		_drawsRight = NO;
        
        _objectCountStringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask], NSFontAttributeName,
																					[[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
																					nil, nil];
    }
    return self;
}

- (void)loadImages
{	
	_addTabButtonImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNew"]];
    _addTabButtonPressedImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewPressed"]];
    _addTabButtonRolloverImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewRollover"]];
	
	_gradientImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AdiumGradient"]];
}

- (void)dealloc
{
	[_addTabButtonImage release];
	[_addTabButtonPressedImage release];
	[_addTabButtonRolloverImage release];
	
	[_gradientImage release];
	
    [_objectCountStringAttributes release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing Style Accessors

- (BOOL)drawsUnified
{
	return _drawsUnified;
}

- (void)setDrawsUnified:(BOOL)value
{
	_drawsUnified = value;
}

- (BOOL)drawsRight
{
	return _drawsRight;
}

- (void)setDrawsRight:(BOOL)value
{
	_drawsRight = value;
}

#pragma mark -
#pragma mark Control Specific

- (float)leftMarginForTabBarControl
{
    return 0.0f;
}

- (float)rightMarginForTabBarControl
{
    return 24.0f;
}

- (float)topMarginForTabBarControl
{
	return 0.0f;
}

- (void)setOrientation:(PSMTabBarOrientation)value
{
	orientation = value;
}

#pragma mark -
#pragma mark Add Tab Button

- (NSImage *)addTabButtonImage
{
    return _addTabButtonImage;
}

- (NSImage *)addTabButtonPressedImage
{
    return _addTabButtonPressedImage;
}

- (NSImage *)addTabButtonRolloverImage
{
    return _addTabButtonRolloverImage;
}

#pragma mark -
#pragma mark Cell Specific

- (NSRect)dragRectForTabCell:(PSMTabBarCell *)cell orientation:(PSMTabBarOrientation)tabOrientation
{
	NSRect dragRect = [cell frame];
	
	if ([cell tabState] & PSMTab_SelectedMask) {
		if (tabOrientation == PSMTabBarHorizontalOrientation) {
			dragRect.size.width++;
			dragRect.size.height -= 2.0;
		}
	}
	
	return dragRect;
}

- (BOOL)closeButtonIsEnabledForCell:(PSMTabBarCell *)cell
{
	return ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]);
	
}
- (NSRect)closeButtonRectForTabCell:(PSMTabBarCell *)cell withFrame:(NSRect)cellFrame
{
	if ([self closeButtonIsEnabledForCell:cell] == NO)
		return NSZeroRect;
	
	NSRect result = cellFrame;
	result.size = (NSSize){12.0, 12.0};
	result.origin.x += 8.0;
	result.origin.y += [cell state] == NSOnState ? 5.0 : 4.0;
	return result;
}

- (NSRect)iconRectForTabCell:(PSMTabBarCell *)cell
{
	if ([cell hasIcon] == NO) {
		return NSZeroRect;
	}

	NSRect cellFrame = [cell frame];
	NSImage *icon = [[[cell representedObject] identifier] icon];
	NSSize	iconSize = [icon size];

	NSRect result;
	result.size = iconSize;
	result.origin.x = NSMaxX(cellFrame) - 8.0 - iconSize.width;
	result.origin.y = cellFrame.origin.y + (cellFrame.size.height - iconSize.height) / 2;

	return result;
}

- (NSRect)indicatorRectForTabCell:(PSMTabBarCell *)cell
{
	NSRect cellFrame = [cell frame];

	if ([[cell indicator] isHidden]) {
		return NSZeroRect;
	}

	NSRect result;
	result.size = NSMakeSize(kPSMTabBarIndicatorWidth, kPSMTabBarIndicatorWidth);
	result.origin.x = cellFrame.origin.x + cellFrame.size.width - Adium_MARGIN_X - kPSMTabBarIndicatorWidth;
	result.origin.y = cellFrame.origin.y + MARGIN_Y;

	if ([cell state] == NSOnState) {
		result.origin.y -= 1;
	}

	return result;
}

- (NSSize)sizeForObjectCounterRectForTabCell:(PSMTabBarCell *)cell
{
	NSSize size;
	float countWidth = [[self attributedObjectCountValueForTabCell:cell] size].width;

	countWidth += (2 * kPSMAdiumObjectCounterRadius - 6.0);
	
	if (countWidth < kPSMAdiumCounterMinWidth) {
		countWidth = kPSMAdiumCounterMinWidth;
	}
	
	size = NSMakeSize(countWidth, 2 * kPSMAdiumObjectCounterRadius); // temp

	return size;
}

- (NSRect)objectCounterRectForTabCell:(PSMTabBarCell *)cell
{
	NSRect cellFrame;
	NSRect result;

	if ([cell count] == 0) {
		return NSZeroRect;
	}

	cellFrame = [cell frame];
	result.size = [self sizeForObjectCounterRectForTabCell:cell];
	result.origin.x = NSMaxX(cellFrame) - Adium_MARGIN_X - result.size.width;
	result.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;

	if (![[cell indicator] isHidden]) {
		result.origin.x -= kPSMTabBarIndicatorWidth + Adium_CellPadding;
	}

	return result;
}

- (float)minimumWidthOfTabCell:(PSMTabBarCell *)cell
{
	float resultWidth = 0.0;

	// left margin
	resultWidth = Adium_MARGIN_X;

	// close button?
	if ([self closeButtonIsEnabledForCell:cell]) {
		resultWidth += NSWidth([self closeButtonRectForTabCell:cell withFrame:[cell frame]]) + Adium_CellPadding;
	}

	// icon?
	/*if ([cell hasIcon]) {
		resultWidth += kPSMTabBarIconWidth + Adium_CellPadding;
	}*/

	// the label
	resultWidth += kPSMMinimumTitleWidth;

	// object counter?
	if (([cell count] > 0) && (orientation == PSMTabBarHorizontalOrientation)) {
		resultWidth += NSWidth([self objectCounterRectForTabCell:cell]) + Adium_CellPadding;
	}

	// indicator?
	if ([[cell indicator] isHidden] == NO) {
		resultWidth += Adium_CellPadding + kPSMTabBarIndicatorWidth;
	}

	// right margin
	resultWidth += Adium_MARGIN_X;

	return ceil(resultWidth);
}

- (float)desiredWidthOfTabCell:(PSMTabBarCell *)cell
{
	float resultWidth = 0.0;

	// left margin
	resultWidth = Adium_MARGIN_X;

	// close button?
	if ([self closeButtonIsEnabledForCell:cell]) {
		resultWidth += NSWidth([self closeButtonRectForTabCell:cell withFrame:[cell frame]]) + Adium_CellPadding;
	}

	// icon?
	/*if ([cell hasIcon]) {
		resultWidth += kPSMTabBarIconWidth + Adium_CellPadding;
	}*/

	// the label
	resultWidth += [[cell attributedStringValue] size].width + Adium_CellPadding;

	// object counter?
	if (([cell count] > 0) && (orientation == PSMTabBarHorizontalOrientation)){
		resultWidth += [self objectCounterRectForTabCell:cell].size.width + Adium_CellPadding;
	}

	// indicator?
	if ([[cell indicator] isHidden] == NO) {
		resultWidth += Adium_CellPadding + kPSMTabBarIndicatorWidth;
	}

	// right margin
	resultWidth += Adium_MARGIN_X;

	return ceil(resultWidth);
}

- (float)tabCellHeight
{
	return 21;
}

#pragma mark -
#pragma mark Cell Values

- (NSAttributedString *)attributedObjectCountValueForTabCell:(PSMTabBarCell *)cell
{
	NSString *contents = [NSString stringWithFormat:@"%i", [cell count]];
    return [[[NSMutableAttributedString alloc] initWithString:contents attributes:_objectCountStringAttributes] autorelease];
}

- (NSAttributedString *)attributedStringValueForTabCell:(PSMTabBarCell *)cell
{
	NSMutableAttributedString *attrStr;
	NSString *contents = [cell stringValue];
	attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
	NSRange range = NSMakeRange(0, [contents length]);

	// Add font attribute
	[attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];
	[attrStr addAttribute:NSForegroundColorAttributeName value:[NSColor controlTextColor] range:range];

	// Paragraph Style for Truncating Long Text
	static NSMutableParagraphStyle *TruncatingTailParagraphStyle = nil;
	if (!TruncatingTailParagraphStyle) {
		TruncatingTailParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] retain];
		[TruncatingTailParagraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	}
	[attrStr addAttribute:NSParagraphStyleAttributeName value:TruncatingTailParagraphStyle range:range];

	return attrStr;
}

#pragma mark -
#pragma mark Cell Drawing

- (float)heightOfAttributedString:(NSAttributedString *)inAttributedString withWidth:(float)width
{
    NSTextStorage		*textStorage;
    NSTextContainer 	*textContainer;
    NSLayoutManager 	*layoutManager;
	float				height;
	
    //Setup the layout manager and text container
    textStorage = [[NSTextStorage alloc] initWithAttributedString:inAttributedString];
    textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, 1e7)];
    layoutManager = [[NSLayoutManager alloc] init];
	
    //Configure
    [textContainer setLineFragmentPadding:0.0];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
	
    //Force the layout manager to layout its text
    (void)[layoutManager glyphRangeForTextContainer:textContainer];
	
	height = [layoutManager usedRectForTextContainer:textContainer].size.height;
	
	[textStorage release];
	[textContainer release];
	[layoutManager release];
	
    return height;
}

- (void)drawObjectCounterInCell:(PSMTabBarCell *)cell withRect:(NSRect)myRect
{
	[[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineWidth:1.0];
	
	if ([cell state] == NSOnState) {
		myRect.origin.y -= 1.0;
	}
	
	[path moveToPoint:NSMakePoint(NSMinX(myRect) + kPSMAdiumObjectCounterRadius, NSMinY(myRect))];
	[path lineToPoint:NSMakePoint(NSMaxX(myRect) - kPSMAdiumObjectCounterRadius, NSMinY(myRect))];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(myRect) - kPSMAdiumObjectCounterRadius, NSMinY(myRect) + kPSMAdiumObjectCounterRadius) 
									 radius:kPSMAdiumObjectCounterRadius
								 startAngle:270.0
								   endAngle:90.0];
	[path lineToPoint:NSMakePoint(NSMinX(myRect) + kPSMAdiumObjectCounterRadius, NSMaxY(myRect))];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(myRect) + kPSMAdiumObjectCounterRadius, NSMinY(myRect) + kPSMAdiumObjectCounterRadius) 
									 radius:kPSMAdiumObjectCounterRadius
								 startAngle:90.0
								   endAngle:270.0];
	[path fill];
	
	// draw attributed string centered in area
	NSRect counterStringRect;
	NSAttributedString *counterString = [self attributedObjectCountValueForTabCell:cell];
	counterStringRect.size = [counterString size];
	counterStringRect.origin.x = myRect.origin.x + ((myRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
	counterStringRect.origin.y = myRect.origin.y + ((myRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
	[counterString drawInRect:counterStringRect];
}

- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView
{
	NSRect cellFrame = [cell frame];

	NSInteger selectedIndex = [[tabBar tabView] indexOfTabViewItem:[[tabBar tabView] 
		selectedTabViewItem]];
	NSInteger cellIndex = [[tabBar cells] indexOfObject:cell];
	NSInteger lastIndex = [[tabBar cells] indexOfObject:[tabBar lastVisibleTab]];
	BOOL needsSeparator = cellIndex != selectedIndex && 
		cellIndex != selectedIndex - 1 && 
		cellIndex < lastIndex;
	if (needsSeparator)
	{
		NSImage *separator = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle mainBundle] pathForImageResource:@"tabbar_divider"]];
		NSPoint origin = (NSPoint){NSMaxX(cellFrame) - [separator size].width, NSMinY(cellFrame)};
		if ([controlView isFlipped])
			origin.y += [separator size].height;
		[separator compositeToPoint:origin operation:NSCompositeSourceOver fraction:1.0];
		[separator release];
	}
	

	// label rect
	NSRect labelRect;
	labelRect.origin.x = cellFrame.origin.x + Adium_MARGIN_X;
	labelRect.size.width = cellFrame.size.width - (labelRect.origin.x - cellFrame.origin.x) - Adium_CellPadding;
	labelRect.size.height = cellFrame.size.height;
	
	switch (orientation)
	{
		case PSMTabBarHorizontalOrientation:
			labelRect.origin.y = cellFrame.origin.y + MARGIN_Y + ([cell state] == NSOnState ? 1.0 : 0.0);
			break;
		case PSMTabBarVerticalOrientation:
			labelRect.origin.y = cellFrame.origin.y;
			break;
	}
	
	if ([self closeButtonIsEnabledForCell:cell])
	{
		NSString *state = [cell state] == NSOnState ? @"on" : @"off";
		NSString *closeBtnImageName = [cell closeButtonOver] 
			? @"tabbar_close_%@_over" 
			: @"tabbar_close_%@_up";
		closeBtnImageName = [NSString stringWithFormat:closeBtnImageName, state];
		NSImage *closeBtnImage = [[NSImage alloc] initWithContentsOfFile:
			[[NSBundle mainBundle] pathForImageResource:closeBtnImageName]];
		
		/* The close button and the icon (if present) are drawn combined, changing on-hover */
		NSRect closeButtonRect = [cell closeButtonRectForFrame:cellFrame];
		
		if ([controlView isFlipped])
			closeButtonRect.origin.y += closeButtonRect.size.height;
		
		[closeBtnImage compositeToPoint:closeButtonRect.origin 
			operation:NSCompositeSourceOver fraction:1.0];
		[closeBtnImage release];
	}
	if ([cell hasIcon]) 
	{
		/* The close button is disabled; the cell has an icon */
		NSRect iconRect = [self iconRectForTabCell:cell];
		NSImage *icon = [[[cell representedObject] identifier] icon];

		if ([controlView isFlipped]) {
			iconRect.origin.y += iconRect.size.height;
		}

		[icon compositeToPoint:iconRect.origin operation:NSCompositeSourceOver fraction:1.0];
		
		// scoot label over by the size of the standard close button
		labelRect.origin.x += (NSWidth(iconRect) + Adium_CellPadding);
		labelRect.size.width -= (NSWidth(iconRect) + Adium_CellPadding);
	}
	
	if (![[cell indicator] isHidden])
	{
		labelRect.size.width -= (kPSMTabBarIndicatorWidth + Adium_CellPadding);
	}
    
	// object counter
	//The object counter takes up space horizontally...
	if (([cell count] > 0) &&
		(orientation == PSMTabBarHorizontalOrientation)) {
		NSRect counterRect = [self objectCounterRectForTabCell:cell];
		
		[self drawObjectCounterInCell:cell withRect:counterRect];
		labelRect.size.width -= NSWidth(counterRect) + Adium_CellPadding;
	}
	
	// draw label
	NSAttributedString *attributedString = [cell attributedStringValue];
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	NSColor *color;
	if ([cell state] == NSOnState)
	{
		color = [NSColor colorWithCalibratedRed:0.906 green:0.906 blue:0.906 alpha:1.0];
	}
	else
	{
		color = [NSColor colorWithCalibratedRed:0.149 green:0.149 blue:0.149 alpha:1.0];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5]];
		[shadow setShadowBlurRadius:0.0];
		[shadow setShadowOffset:(NSSize){0.0, -1.0}];
		[attributes setObject:shadow forKey:NSShadowAttributeName];
		[shadow release];
	}
	NSFont *font = [NSFont boldSystemFontOfSize:11.0];
	[attributes setObject:color forKey:NSForegroundColorAttributeName];
	[attributes setObject:font forKey:NSFontAttributeName];
	NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] 
		initWithAttributedString:attributedString];
	[mutableAttributedString addAttributes:attributes 
		range:(NSRange){0, [mutableAttributedString length]}];
	
	labelRect.size.width = MIN(cellFrame.size.width - 40.0, [mutableAttributedString size].width);
	labelRect.origin.x = round(cellFrame.size.width - labelRect.size.width) / 2 + cellFrame.origin.x;
		
	[mutableAttributedString drawInRect:labelRect];
	[mutableAttributedString release];
}

- (void)drawTabCell:(PSMTabBarCell *)cell
{
	NSRect cellFrame = [cell frame];
	if ([cell state] == NSOnState)
	{
		NSDrawThreePartImage(cellFrame, [NSImage imageNamed:@"tabbar_activetab_left.png"], 
			[NSImage imageNamed:@"tabbar_activetab_middle.png"], 
			[NSImage imageNamed:@"tabbar_activetab_right.png"], 
			NO, NSCompositeSourceAtop, 1.0, YES);
	} 
	else 
	{	
	}
	[self drawInteriorWithTabCell:cell inView:[cell controlView]];
}

- (void)drawBackgroundInRect:(NSRect)rect
{
//	NSImage *background = [NSImage imageNamed:@"tabbar_background.png"];
//	[background setFlipped:YES];
//	[background drawInRect:[tabBar bounds] fromRect:NSZeroRect operation:NSCompositeSourceAtop 
//		fraction:1.0];
}

- (void)drawTabBar:(PSMTabBarControl *)bar inRect:(NSRect)rect
{
	if (orientation != [bar orientation]) {
		orientation = [bar orientation];
	}
	
	if (tabBar != bar) {
		tabBar = bar;
	}
	
	[self drawBackgroundInRect:rect];
	
	// no tab view == not connected
	if (![bar tabView]) {
		NSRect labelRect = rect;
		labelRect.size.height -= 4.0;
		labelRect.origin.y += 4.0;
		NSMutableAttributedString *attrStr;
		NSString *contents = @"PSMTabBarControl";
		attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
		NSRange range = NSMakeRange(0, [contents length]);
		[attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];
		NSMutableParagraphStyle *centeredParagraphStyle = nil;
		
		if (!centeredParagraphStyle) {
			centeredParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			[centeredParagraphStyle setAlignment:NSCenterTextAlignment];
		}
		
		[attrStr addAttribute:NSParagraphStyleAttributeName value:centeredParagraphStyle range:range];
		[attrStr drawInRect:labelRect];
		[centeredParagraphStyle release];
		return;
	}

	// draw cells
	NSEnumerator *e = [[bar cells] objectEnumerator];
	PSMTabBarCell *cell;
	while ( (cell = [e nextObject]) ) {
		if ([bar isAnimating] || (![cell isInOverflowMenu] && NSIntersectsRect([cell frame], rect))) {
			[cell drawWithFrame:[cell frame] inView:bar];
		}
	}
}

#pragma mark -
#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder 
{
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:_addTabButtonImage forKey:@"addTabButtonImage"];
        [aCoder encodeObject:_addTabButtonPressedImage forKey:@"addTabButtonPressedImage"];
        [aCoder encodeObject:_addTabButtonRolloverImage forKey:@"addTabButtonRolloverImage"];
		[aCoder encodeBool:_drawsUnified forKey:@"drawsUnified"];
		[aCoder encodeBool:_drawsRight forKey:@"drawsRight"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
   if ( (self = [super init]) ) {
        if ([aDecoder allowsKeyedCoding]) {
            _addTabButtonImage = [[aDecoder decodeObjectForKey:@"addTabButtonImage"] retain];
            _addTabButtonPressedImage = [[aDecoder decodeObjectForKey:@"addTabButtonPressedImage"] retain];
            _addTabButtonRolloverImage = [[aDecoder decodeObjectForKey:@"addTabButtonRolloverImage"] retain];
			_drawsUnified = [aDecoder decodeBoolForKey:@"drawsUnified"];
			_drawsRight = [aDecoder decodeBoolForKey:@"drawsRight"];
        }
    }
    return self;
}

@end
