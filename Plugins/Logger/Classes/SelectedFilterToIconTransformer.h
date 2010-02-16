//
//  SelectedFilterToIconTransformer.h
//  Trazzle
//
//  Created by Marc Bauer on 26.06.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LPFilter.h"

@class LPFilterWindowController;

@interface SelectedFilterToIconTransformer : NSValueTransformer{
	LPFilterWindowController *m_filterController;
}
- (id)initWithFilterController:(LPFilterWindowController *)filterController;
@end