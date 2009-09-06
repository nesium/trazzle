//
//  ZZWindow.h
//  Trazzle
//
//  Created by Marc Bauer on 23.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZZWindow : NSWindow 
{
	BOOL m_forceDisplay;
	
	CGFloat m_topBorderHeight;
	CGFloat m_bottomBorderHeight;
	
	NSColor *m_borderStartColor;
	NSColor *m_borderEndColor;
	NSColor *m_borderEdgeColor;
	NSColor *m_borderStartColorInactive;
	NSColor *m_borderEndColorInactive;
	NSColor *m_borderEdgeColorInactive;

	NSColor *m_backgroundFillColor;
}
@property (nonatomic, retain) NSColor *borderStartColor;
@property (nonatomic, retain) NSColor *borderEndColor;
@property (nonatomic, retain) NSColor *borderEdgeColor;
@property (nonatomic, retain) NSColor *backgroundFillColor;
@property (nonatomic, retain) NSColor *borderStartColorInactive;
@property (nonatomic, retain) NSColor *borderEndColorInactive;
@property (nonatomic, retain) NSColor *borderEdgeColorInactive;
@property (nonatomic, assign) CGFloat topBorderHeight;
@property (nonatomic, assign) CGFloat bottomBorderHeight; 
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask 
	backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
@end