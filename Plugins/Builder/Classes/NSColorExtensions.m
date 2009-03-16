#import "NSColorExtensions.h"


@implementation NSColor (NSColorExtensions)

+ (NSColor *) ColorFromHexRepresentation: (NSString *) hexRepresentation
{
	NSScanner *hexScanner = [NSScanner scannerWithString: [hexRepresentation substringFromIndex: 1]];
	unsigned hexValue;	
	[hexScanner scanHexInt: &hexValue];
	
	float red = ((hexValue >> 16) & 0xFF) / 255.0;
	float green = ((hexValue >> 8) & 0xFF) / 255.0;
	float blue = (hexValue & 0xFF) / 255.0;
	
	return [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1.0];
}

- (NSString *) hexRepresentation
{
	int red	= [self redComponent] * 255;
	int green = [self greenComponent] * 255;
	int blue = [self blueComponent] * 255;

	NSString * str = [NSString stringWithFormat: @"#%x", ((red << 16) | (green << 8) | blue)];

	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"uppercaseColorCodes"])
       str = [str uppercaseString];
   
	return str;
}

@end
