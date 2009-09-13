//
//  NSColor+Additions.m
//  RSFGameServer
//
//  Created by Marc Bauer on 24.10.08.
//  Copyright 2008 Fork Unstable Media GmbH. All rights reserved.
//

#import "NSColor+Additions.h"


@implementation NSColor (Additions)

- (CGColorRef)CGColorCopy
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSColor *deviceColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	float components[4];
	[deviceColor getRed:&components[0] green:&components[1] blue:&components[2] 
		alpha:&components[3]];
	CGColorRef color = CGColorCreate(colorSpace, components);
	CGColorSpaceRelease(colorSpace);
	return color;
}

+ (NSColor *)colorFromHexRGB:(NSString *)inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void)[scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte = (unsigned char)(colorCode >> 16);
	greenByte = (unsigned char)(colorCode >> 8);
	blueByte = (unsigned char)(colorCode);	// masks off high bits
	result = [NSColor colorWithCalibratedRed:((float)redByte / 0xff) 
		green:((float)greenByte / 0xff) blue:((float)blueByte / 0xff) alpha:1.0];
	return result;
}

-(NSString *)hexString
{
	float redFloatValue, greenFloatValue, blueFloatValue;
	int redIntValue, greenIntValue, blueIntValue;
	NSString *redHexValue, *greenHexValue, *blueHexValue;

	// Convert the NSColor to the RGB color space before we can access its components
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if (convertedColor)
	{
		// Get the red, green, and blue components of the color
		[convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue 
			alpha:NULL];

		// Convert the components to numbers (unsigned decimal integer) between 0 and 255
		redIntValue = redFloatValue * 255.99999f;
		greenIntValue = greenFloatValue * 255.99999f;
		blueIntValue = blueFloatValue * 255.99999f;

		// Convert the numbers to hex strings
		redHexValue = [NSString stringWithFormat:@"%02x", redIntValue];
		greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
		blueHexValue = [NSString stringWithFormat:@"%02x", blueIntValue];

		// Concatenate the red, green, and blue components' hex strings together with a "#"
		return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
	}
	return nil;
}


@end