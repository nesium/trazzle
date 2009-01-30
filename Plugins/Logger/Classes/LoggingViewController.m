//
//  LoggingViewController.m
//  Trazzle
//
//  Created by Marc Bauer on 15.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "LoggingViewController.h"


@implementation LoggingViewController

- (void)awakeFromNib
{
	[[m_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:
		[NSURL URLWithString:[[[NSBundle bundleForClass:[self class]] 
			pathForResource:@"theme" ofType:@"html"] 
			stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
}

@end