#import "BLDCompilerSettingsWindowController.h"
#import "Model.h"


@interface BLDCompilerSettingsWindowController (Private)
- (NSButtonCell *) buttonCell;
- (NSComboBoxCell *) comboBoxCell;
- (NSPopUpButtonCell *) popUpButtonCell;
- (FMTColorCell *) colorCell;
- (FMTFileChooserCell *) fileChooserCell;
- (NSFont *) miniFont;
- (void) loadCompilerSettings;
@end


Model *m_data;


@implementation BLDCompilerSettingsWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"CompilerSettingsWindow"])
	{
		[self loadCompilerSettings];
		cogIcon = [[NSImage alloc] initWithContentsOfFile: [[NSBundle bundleForClass: [self class]] 
			pathForImageResource: @"cog.png"]];
		[self showWindow:self];
	}
	return self;
}

- (void) loadCompilerSettings
{
	NSString *path = [[[NSBundle bundleForClass: [self class]] resourcePath] 
		stringByAppendingPathComponent: @"AS2_CompilerSettingsConfig.plist"];
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	plistData = [NSData dataWithContentsOfFile: path];
	m_settings = (NSMutableArray *)[[NSPropertyListSerialization propertyListFromData: plistData
		mutabilityOption: NSPropertyListMutableContainersAndLeaves
		format: &format errorDescription: &error] retain];
	if (!m_settings)
	{
		NSLog(error);
		[error release];
		exit(0);
	}
	m_data = [[Model alloc] initWithCompilerSettingsConfig: m_settings];
}

- (void) awakeFromNib
{
	int i;
	NSTableColumn *tableColumn;
	for (i = 0; i < [m_settingsTable numberOfColumns]; i++)
	{
		tableColumn = [[m_settingsTable tableColumns] objectAtIndex: i];		
		if ([[tableColumn identifier] isEqualToString: @"icon"])
		{
			continue;
		}
		[[tableColumn headerCell] setFont: [self miniFont]];		
		[tableColumn setDataCell: [[[RSVerticallyCenteredTextFieldCell alloc] init] autorelease]];		
		[[tableColumn dataCell] setFont: [self miniFont]];
		[[tableColumn dataCell] setLineBreakMode: NSLineBreakByTruncatingMiddle];
	}
	[m_settingsTable setDelegate: self];
	[m_settingsTable setDataSource: self];
}


static NSButtonCell *g_buttonCell = nil;
static NSComboBoxCell *g_comboBoxCell = nil;
static NSPopUpButtonCell *g_popUpButtonCell = nil;
static FMTColorCell *g_colorCell = nil;
static FMTFileChooserCell *g_fileChooserCell = nil;

- (NSButtonCell *) buttonCell
{
	if (g_buttonCell == nil)
	{
		g_buttonCell = [[NSButtonCell alloc] init];
		[g_buttonCell setButtonType: NSSwitchButton];
		[g_buttonCell setControlSize: NSSmallControlSize];
		[g_buttonCell setTitle: @""];
	}
	return g_buttonCell;
}

- (NSComboBoxCell *) comboBoxCell
{
	if (g_comboBoxCell == nil)
	{
		g_comboBoxCell = [[NSComboBoxCell alloc] init];
		[g_comboBoxCell setFont: [self miniFont]];
		[g_comboBoxCell setItemHeight: 15.0];
		[g_comboBoxCell setEditable: YES];
		[g_comboBoxCell setControlSize: NSMiniControlSize];
	}
	return g_comboBoxCell;	
}

- (NSPopUpButtonCell *) popUpButtonCell
{
	if (g_popUpButtonCell == nil)
	{
		g_popUpButtonCell = [[NSPopUpButtonCell alloc] init];
		[g_popUpButtonCell setControlSize: NSMiniControlSize];
	}
	return g_popUpButtonCell;
}

- (FMTColorCell *) colorCell
{
	if (g_colorCell == nil)
	{
		g_colorCell = [[FMTColorCell alloc] init];
		[g_colorCell setFont: [self miniFont]];
		[g_colorCell setTarget: self];
		[g_colorCell setAction: @selector(colorClick:)];
	}
	return g_colorCell;
}

- (FMTFileChooserCell *) fileChooserCell
{
	if (g_fileChooserCell == nil)
	{
		g_fileChooserCell = [[FMTFileChooserCell alloc] init];
		[g_fileChooserCell setFont: [self miniFont]];
		[g_fileChooserCell setTarget: self];
		[g_fileChooserCell setAction: @selector(fileChooserClick:)];
		[g_fileChooserCell setLineBreakMode: NSLineBreakByTruncatingMiddle];
	}
	return g_fileChooserCell;
}

- (NSFont *) miniFont
{
	return [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSMiniControlSize]];
}

NSString *m_lastOpenedDirectory;
- (void) fileChooserClick: (id) sender
{
	NSArray *flags = m_settings;
	NSMutableDictionary *rowData = [flags objectAtIndex: [sender clickedRow]];
	NSDictionary *panelConfig = [rowData objectForKey: @"panel"];
	NSString *file = [rowData objectForKey: @"content"];
	
	NSString *panelType = [panelConfig objectForKey: @"type"];
	id panel;
	if ([panelType isEqualToString: @"open"])
	{
		panel = [NSOpenPanel openPanel];
		[panel setCanChooseDirectories: NO];
		[panel setAllowsMultipleSelection: NO];
	}
	else if ([panelType isEqualToString: @"save"])
	{
		panel = [NSSavePanel savePanel];
		[panel setCanCreateDirectories: YES];
	}
	else
	{
		return;
	}
	
	NSString *directory = m_lastOpenedDirectory == nil ? 
		NSHomeDirectory() : m_lastOpenedDirectory;	
	[panel setExtensionHidden: NO];
	NSLog(@"%@", [panelConfig objectForKey: @"allowedFileTypes"]);

	int result = [panel runModalForDirectory: directory file: file 
		types: [panelConfig objectForKey: @"allowedFileTypes"]];
	if (result == NSFileHandlingPanelCancelButton)
		return;

	[m_lastOpenedDirectory release];
	m_lastOpenedDirectory = [[[panel filename] stringByDeletingLastPathComponent] retain];
	[m_data setValue: [panel filename] atIndex: [sender clickedRow]];
	[m_settingsTable reloadData];
}

int m_colorRow;
- (void) colorClick: (id) sender
{
	m_colorRow = [sender clickedRow];
	NSArray *flags = m_settings;
	NSDictionary *rowData = [flags objectAtIndex: m_colorRow];
	
	NSColorPanel* panel = [NSColorPanel sharedColorPanel];
	[panel setTarget: self];
	[panel setAction: @selector(colorChanged:)];
	[panel setShowsAlpha: NO];
	[panel setColor: [NSColor ColorFromHexRepresentation: [rowData objectForKey: @"content"]]];
	[panel makeKeyAndOrderFront: self];
}

- (void) colorChanged: (id) sender
{
	[m_data setValue: [[sender color] hexRepresentation] atIndex: m_colorRow];
	[m_settingsTable reloadData];
}



//--------------------------------------------------------------------------------------------------
//								Table delegate & dataSource methods
//--------------------------------------------------------------------------------------------------
- (id) tableView: (NSTableView *) tableView dataCellForRow: (int) row 
	ofColumn: (NSTableColumn *) col
{
	NSArray *flags = m_settings;
	NSDictionary *rowData = [flags objectAtIndex: row];
	NSString *dataType = [rowData objectForKey: @"type"];

	if ([dataType isEqualToString: @"flag"])
	{
		return [self buttonCell];
	}
	else if ([dataType isEqualToString: @"editable_list"])
	{
		return [self comboBoxCell];
	}
	else if ([dataType isEqualToString: @"list"])
	{
		return [self popUpButtonCell];
	}
	else if ([dataType isEqualToString: @"color"])
	{
		return [self colorCell];
	}
	else if ([dataType isEqualToString: @"file"])
	{
		return [self fileChooserCell];
	}
	else
	{
		return [col dataCell];
	}
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [m_settings count];
}

- (id) tableView: (NSTableView *) aTableView
    objectValueForTableColumn: (NSTableColumn *) aTableColumn
    row: (int) row
{
	if ([[aTableColumn identifier] isEqualToString: @"icon"])
	{
		return cogIcon;
	}
	else if ([[aTableColumn identifier] isEqualToString: @"setting"])
	{
		return [[m_settings objectAtIndex: row] objectForKey: @"title"];
	}
	return [m_data valueAtIndex: row];
}

- (void) tableView: (NSTableView*) tableView willDisplayCell: (id) cell 
	forTableColumn: (NSTableColumn*) tableColumn row: (int) row
{
	if (![[tableColumn identifier] isEqualToString: @"value"])
	{
		return;
	}
	
	NSArray *flags = m_settings;
	NSMutableDictionary *rowData = [flags objectAtIndex: row];	
	NSMutableArray *items = [rowData objectForKey: @"list"];
	NSString *dataType = [rowData objectForKey: @"type"];	
	
	if ([dataType isEqualToString: @"editable_list"])
	{
		[cell removeAllItems];
		[cell addItemsWithObjectValues: items];		
	}
	else if ([dataType isEqualToString: @"list"])
	{
		int i;
		NSMenu *menu = [[NSMenu alloc] init];
		NSMenuItem *item;
		for (i = 0; i < [items count]; i++)
		{
			NSAttributedString *title = [[NSAttributedString alloc] 
				initWithString: [[items objectAtIndex: i] objectForKey: @"label"]
				attributes: [NSDictionary dictionaryWithObject: [self miniFont]					
					forKey: NSFontAttributeName]];
			item = [[NSMenuItem alloc] initWithTitle: @"" action: nil keyEquivalent: @""];
			[item setAttributedTitle: title];
			[menu addItem: item];
			[item release];
		}		
		[cell setMenu: menu];
		[cell setObjectValue: [m_data valueAtIndex: row]];
		[menu release];
	}
	
	if ([cell isKindOfClass: [RSVerticallyCenteredTextFieldCell class]] ||
		[cell isKindOfClass: [FMTColorCell class]])
	{
		[cell setEditable: YES];
	}
}

- (void) tableView: (NSTableView *) aTableView setObjectValue: (id) anObject 
	forTableColumn: (NSTableColumn *) aTableColumn row: (int) row
{
	NSArray *flags = m_settings;
	NSMutableDictionary *rowData = [flags objectAtIndex: row];
	NSString *dataType = [rowData objectForKey: @"type"];

	[m_data setValue: anObject atIndex: row];
	[m_data compilerString];

	if ([dataType isEqualToString: @"editable_list"])
	{
		NSMutableArray *items = [rowData objectForKey: @"list"];
		if ([items containsObject: anObject])
		{
			return;
		}
		[items addObject: anObject];
	}
	else if ([dataType isEqualToString: @"color"])
	{
		if (m_colorRow == row && [[NSColorPanel sharedColorPanel] isVisible] &&
			[[NSColorPanel sharedColorPanel] valueForKey: @"target"] == self)
		{
			[[NSColorPanel sharedColorPanel] setColor: 
				[NSColor ColorFromHexRepresentation: (NSString *)anObject]];
		}
	}	
}
@end
