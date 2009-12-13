//
//  LPFilterModel.h
//  Logger
//
//  Created by Marc Bauer on 22.08.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LPFilter.h"


@interface LPFilterModel : NSObject{
	LPFilter *m_activeFilter;
	BOOL m_filteringIsEnabled;
	BOOL m_showsFlashLogMessages;
}
@property (nonatomic, retain) LPFilter *activeFilter;
@property (nonatomic, assign) BOOL filteringIsEnabled;
@property (nonatomic, assign) BOOL showsFlashLogMessages;
@property (nonatomic, readonly) NSArray *filters;
- (void)save;
- (LPFilter *)addNewFilter;
- (void)addFilter:(LPFilter *)aFilter;
- (void)removeFilter:(LPFilter *)aFilter;
- (LPFilter *)duplicateFilter:(LPFilter *)aFilter;
@end