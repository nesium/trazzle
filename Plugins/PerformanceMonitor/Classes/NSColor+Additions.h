//
//  NSColor+Additions.h
//  RSFGameServer
//
//  Created by Marc Bauer on 24.10.08.
//  Copyright 2008 Fork Unstable Media GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface NSColor (Additions)
- (CGColorRef)CGColorCopy;
+ (NSColor *)colorFromHexRGB:(NSString *)inColorString;
@end