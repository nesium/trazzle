//
//  SelectedFilterToIconTransformer.h
//  Trazzle
//
//  Created by Marc Bauer on 26.06.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LPFilter.h"

@class LPFilterController;

@interface SelectedFilterToIconTransformer : NSValueTransformer{
	LPFilterController *m_filterController;
}
- (id)initWithFilterController:(LPFilterController *)filterController;
@end