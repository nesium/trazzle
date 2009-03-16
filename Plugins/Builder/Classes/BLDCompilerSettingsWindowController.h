/* Controller */

#import <Cocoa/Cocoa.h>
#import "RSVerticallyCenteredTextFieldCell.h"
#import "FMTColorCell.h"
#import "NSColorExtensions.h"
#import "FMTFileChooserCell.h"

@interface BLDCompilerSettingsWindowController : NSWindowController
{
	IBOutlet NSTableView *m_settingsTable;
	NSMutableArray *m_settings;
	NSImage *cogIcon;
}
@end
