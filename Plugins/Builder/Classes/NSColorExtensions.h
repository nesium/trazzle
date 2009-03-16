#import <Cocoa/Cocoa.h>


@interface NSColor (NSColorExtensions)

+ (NSColor *) ColorFromHexRepresentation: (NSString *) hexRepresentation;
- (NSString *) hexRepresentation;

@end
