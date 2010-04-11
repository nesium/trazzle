//
//  IPInspectorPlugin.m
//  Inspector
//
//  Created by Marc Bauer on 17.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "IPInspectorPlugin.h"


@implementation IPInspectorPlugin

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPlugInController:(ZZPlugInController *)aController{
	if (self = [super init]){
		NSLog(@"Inspector loaded");
		m_windowController = [[IPInspectorWindowController alloc] init];
		m_controller = aController;
		[[m_controller sharedGateway] registerService:[[[IPInspectionService alloc] 
			initWithDelegate:self] autorelease] withName:@"InspectionService"];
	}
	return self;
}

- (void)inspectionService:(IPInspectionService *)service shouldInspectObject:(id)anObject 
	forGateway:(AMFRemoteGateway *)gateway{
	[m_windowController displayObject:anObject];
}
@end