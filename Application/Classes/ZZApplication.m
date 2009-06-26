//
//  ZZApplication.m
//  Trazzle
//
//  Created by Marc Bauer on 27.06.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "ZZApplication.h"


@implementation ZZApplication

- (void)sendEvent:(NSEvent *)anEvent
{
	if ([anEvent type] == NSKeyUp)
	{
		if ([[[[self keyWindow] firstResponder] className] isEqualToString:@"WebHTMLView"] && 
			[[self keyWindow] windowController] != nil)
		{
			[[[self keyWindow] windowController] keyUp:anEvent];
			return;
		}		
	}
	[super sendEvent:anEvent];
}

@end