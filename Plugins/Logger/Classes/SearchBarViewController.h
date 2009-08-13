//
//  SearchBarViewController.h
//  Logger
//
//  Created by Marc Bauer on 13.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchBarViewController : NSViewController
{
}
@end




@interface SearchBarView : NSView
{
}
@end



@interface SearchBarDoneButtonCell : NSButtonCell
{
}
@end



@interface SearchBarSearchFieldFieldEditor : NSTextView
{
}
@end



@interface SearchBarSearchField : NSSearchField
{
	SearchBarSearchFieldFieldEditor *m_fieldEditor;
}
@end



@interface SearchBarSearchFieldCell : NSSearchFieldCell
{	
}
@end