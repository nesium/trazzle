//
//  MultiCellTableColumn.m
//  test
//
//  Created by Marc Bauer on 22.07.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MultiCellTableColumn.h"


@implementation MultiCellTableColumn

- (id) dataCellForRow: (int) row 
{
   id cell = nil;
   id tv = [self tableView];
   id delegate = [tv delegate];

   if (delegate) 
   {
       SEL selector = @selector(tableView:dataCellForRow:ofColumn:);
       if ([delegate respondsToSelector:selector]) 
	   {
           cell = [delegate tableView:tv dataCellForRow:row ofColumn: self];
       }
   }
   return cell ? cell : [self dataCell];
}

@end
