#import <Cocoa/Cocoa.h>
#import "NSColorExtensions.h"
#import "RSVerticallyCenteredTextFieldCell.h"
#import "FMTColorSwatchCell.h"


@interface FMTColorCell : RSVerticallyCenteredTextFieldCell
{
	FMTColorSwatchCell *m_swatchCell;
}

@end
