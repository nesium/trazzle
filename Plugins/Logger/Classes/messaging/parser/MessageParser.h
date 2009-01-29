//
//  MessageParser.h
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "LogMessage.h"
#import "CommandMessage.h"
#import "PolicyFileRequest.h"
#import "ConnectionSignature.h"
#import "StackTraceParser.h"
#import "StackTraceItem.h"

@interface MessageParser : NSObject 
{
	NSXMLParser *m_parser;
	NSMutableString *m_currentStringValue;
	NSMutableArray *m_data;
	id m_parentObject;
	id m_currentObject;
	BOOL m_parsingSucceeded;	
}

- (id)initWithXMLString:(NSString *)xmlString;
- (NSArray *)data;

@end