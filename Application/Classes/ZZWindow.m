//
//  ZZWindow.m
//  Trazzle
//
//  Created by Marc Bauer on 23.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZWindow.h"


@implementation ZZWindow

@synthesize topBorderHeight=m_topBorderHeight, 
			bottomBorderHeight=m_bottomBorderHeight, 
			borderStartColor=m_borderStartColor, 
			borderEndColor=m_borderEndColor, 
			borderEdgeColor=m_borderEdgeColor, 
			borderStartColorInactive=m_borderStartColorInactive, 
			borderEndColorInactive=m_borderEndColorInactive, 
			borderEdgeColorInactive=m_borderEdgeColorInactive, 
			backgroundFillColor=m_backgroundFillColor;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask 
	backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	unsigned int newStyle;
	if (styleMask & NSTexturedBackgroundWindowMask)
		newStyle = styleMask;
	else
		newStyle = (NSTexturedBackgroundWindowMask | styleMask);
	
	if (self = [super initWithContentRect:contentRect styleMask:newStyle 
		backing:bufferingType defer:flag])
	{
		m_forceDisplay = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(windowKeyStateChanged:) name:NSWindowDidResignKeyNotification 
			object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(windowKeyStateChanged:) name:NSWindowDidBecomeKeyNotification 
			object:self];
		return self;
	}
	return nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
		name:NSWindowDidResizeNotification object:self];
	[m_borderStartColor release];
	[m_borderEndColor release];
	[m_borderEdgeColor release];
	[m_backgroundFillColor release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
- (void)setToolbar:(NSToolbar *)toolbar
{
	// Only actually call this if we respond to it on this machine
	if ([toolbar respondsToSelector:@selector(setShowsBaselineSeparator:)])
		[toolbar setShowsBaselineSeparator:NO];
	[super setToolbar:toolbar];
}
#endif

- (void)setMinSize:(NSSize)aSize
{
	[super setMinSize:NSMakeSize(MAX(aSize.width, 150.0), MAX(aSize.height, 150.0))];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
	m_forceDisplay = YES;
	[super setFrame:frameRect display:displayFlag animate:animationFlag];
	m_forceDisplay = NO;
}

- (NSColor *)styledBackground
{
	NSColor *startColor, *endColor, *edgeColor;
	if ([self isKeyWindow])
	{
		startColor = m_borderStartColor;
		endColor = m_borderEndColor;
		edgeColor = m_borderEdgeColor;
	}
	else
	{
		startColor = m_borderStartColorInactive;
		endColor = m_borderEndColorInactive;
		edgeColor = m_borderEdgeColorInactive;
	}

	NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor 
		endingColor:endColor];
	
	// Set min width of temporary pattern image to prevent flickering at small widths
	float minWidth = 300.0;
	
	// Create temporary image for top gradient
	NSImage *topImg = [[NSImage alloc] initWithSize:NSMakeSize(
		MAX(minWidth, [self frame].size.width), m_topBorderHeight + 1.0)];
	[topImg lockFocus];
	[gradient drawInRect:NSMakeRect(0, 1, [topImg size].width, [topImg size].height) angle:270.0];
	[topImg unlockFocus];
	
	// Create temporary image for bottom gradient
	NSImage *bottomImg = [[NSImage alloc] initWithSize:NSMakeSize(
		MAX(minWidth, [self frame].size.width), m_bottomBorderHeight + 1.0)];
	[bottomImg lockFocus];
	[gradient drawInRect:NSMakeRect(0, 0, [bottomImg size].width, [bottomImg size].height-1.0) 
		angle:270.0];
	[bottomImg unlockFocus];
	
	// Begin drawing into our main image
	[bg lockFocus];
	
	// Composite current background color into bg
	[m_backgroundFillColor set];
	//[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(0, 0, [bg size].width, [bg size].height));
	
	// Composite bottom gradient
	[bottomImg drawInRect:NSMakeRect(0, 0, [bg size].width, m_bottomBorderHeight) 
		fromRect:NSMakeRect(0, 0, [bg size].width, m_bottomBorderHeight) 
		operation:NSCompositeSourceOver 
		fraction:1.0];
	[bottomImg release];

	// Composite top gradient
	[topImg drawInRect:NSMakeRect(0, [bg size].height - m_topBorderHeight, 
			[bg size].width, m_topBorderHeight) 
		fromRect:NSMakeRect(0, 0, [bg size].width, m_topBorderHeight) 
		operation:NSCompositeSourceOver 
		fraction:1.0];
	[topImg release];

	// draw border edges
	if (!edgeColor)
		[[NSColor colorWithDeviceWhite:0.25 alpha:1.0] setFill];
	else
		[edgeColor setFill];

	NSRectFill(NSMakeRect(0, [bg size].height - m_topBorderHeight, [bg size].width, 1.0));
	NSRectFill(NSMakeRect(0, m_bottomBorderHeight, [bg size].width, 1.0));
	
	[bg unlockFocus];
	[gradient release];
	
	return [NSColor colorWithPatternImage:[bg autorelease]];
}



#pragma mark -
#pragma mark Notifications

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self setBackgroundColor:[self styledBackground]];
	if (m_forceDisplay) [self display];
}

- (void)windowKeyStateChanged:(NSNotification *)aNotification
{
	[self setBackgroundColor:[self styledBackground]];
	if (m_forceDisplay) [self display];
}

@end