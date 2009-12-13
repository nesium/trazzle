//
//  IPInspectorPlugin.h
//  Inspector
//
//  Created by Marc Bauer on 17.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZTrazzlePlugIn.h"
#import "IPInspectionService.h"


@interface IPInspectorPlugin : NSObject <ZZTrazzlePlugIn>{
	ZZPlugInController *m_controller;
}
@end
