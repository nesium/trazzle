//
//  FMFileManagerPlugin.h
//  FileManager
//
//  Created by Marc Bauer on 05.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZTrazzlePlugIn.h"
#import "FMFileService.h"
#import "AMFDuplexGateway.h"


@interface FMFileManagerPlugin : NSObject <ZZTrazzlePlugIn>{
	ZZPlugInController *m_controller;
}
@end