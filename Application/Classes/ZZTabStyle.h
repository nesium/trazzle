//
//  PSMAdiumTabStyle.h
//  PSMTabBarControl
//
//  Created by Kent Sutherland on 5/26/06.
//  Copyright 2006 Kent Sutherland. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import <PSMTabBarControl/PSMTabStyle.h>

@interface ZZTabStyle : NSObject <PSMTabStyle>
{
	NSImage *_addTabButtonImage, *_addTabButtonPressedImage, *_addTabButtonRolloverImage;
	NSImage *_gradientImage;
	
    NSDictionary *_objectCountStringAttributes;
    
	PSMTabBarOrientation orientation;
	PSMTabBarControl *tabBar;
	
	BOOL _drawsUnified, _drawsRight;
}

- (void)loadImages;

- (BOOL)drawsUnified;
- (void)setDrawsUnified:(BOOL)value;
- (BOOL)drawsRight;
- (void)setDrawsRight:(BOOL)value;

- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
