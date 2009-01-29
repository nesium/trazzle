//
//  MessageParser.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MessageParser.h"


@interface MessageParser (Private)
- (void)parseXMLString:(NSString *)xmlString;
- (void)clearCurrentString;
@end


@implementation MessageParser

#pragma mark -
#pragma mark Initialization & deallocation

- (id)initWithXMLString:(NSString *)xmlString
{
	self = [super init];
	[self parseXMLString:xmlString];
	return self;
}

- (void)dealloc
{
	[m_currentStringValue release];
	[m_currentObject release];
	[m_data release];
	[m_parser release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSArray *)data
{
	return m_data;
}



#pragma mark -
#pragma mark Private methods

- (void)parseXMLString:(NSString *)xmlString
{
	m_data = [[NSMutableArray alloc] init];
    m_parser = [[NSXMLParser alloc] initWithData:[xmlString 
		dataUsingEncoding:NSUTF8StringEncoding]];
    [m_parser setDelegate:self];
    [m_parser setShouldResolveExternalEntities:NO];
    m_parsingSucceeded = [m_parser parse];
}



#pragma mark -
#pragma mark SAX parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributes
{
	elementName = [elementName lowercaseString];
	
	if ([elementName isEqualToString:kNodeNameLogMessage])
	{
		LogMessage *message = [[LogMessage alloc] init];

		message.levelName = [attributes objectForKey:kAttributeNameLogLevel];
		message.file = [attributes objectForKey:kAttributeNameFile];
		message.method = [attributes objectForKey:kAttributeNameMethod];
		message.fqClassName = [attributes objectForKey:kAttributeNameClass];
		message.timestamp = [[attributes objectForKey:kAttributeNameTimestamp] doubleValue] / 1000;
		message.line = [[attributes objectForKey:kAttributeNameLine] intValue];
		message.encodeHTML = ![[[attributes objectForKey:kAttributeNameEncodeHTML] lowercaseString]
			isEqualToString:@"false"];

		m_currentObject = m_parentObject = message;
		[m_data addObject:message];
		[message release];
	}
	else if ([elementName isEqualToString:kNodeNameMessage])
	{
		if (![m_parentObject isKindOfClass:[LogMessage class]])
		{
			NSLog(@"Error while parsing message: current node is not of type LogMessage");
			[parser abortParsing];
			return;
		}
	}
	else if ([elementName isEqualToString:kNodeNameStacktrace])
	{
		if (![m_parentObject isKindOfClass:[LogMessage class]])
		{
			NSLog(@"Error while parsing stacktrace: current node is not of type LogMessage");
			[parser abortParsing];
			return;
		}
		m_currentObject = [attributes retain];
	}
	else if ([elementName isEqualToString:kNodeNameCommand])
	{
		m_currentObject = [[CommandMessage alloc] initWithAction: 
			[attributes objectForKey:@"action"] attributes:attributes];
		[m_data addObject:m_currentObject];
		[m_currentObject release];
	}
	else if ([elementName isEqualToString:kNodeNamePolicyFileRequest])
	{
		m_currentObject = [[PolicyFileRequest alloc] init];
		[m_data addObject:m_currentObject];
		[m_currentObject release];
	}
	else if ([elementName isEqualToString:kNodeNameSignature])
	{
		m_currentObject = [[ConnectionSignature alloc] init];
		[(ConnectionSignature *)m_currentObject setStartTime:[NSNumber numberWithDouble:
			([[attributes objectForKey:@"starttime"] doubleValue] / 1000)]];
		[(ConnectionSignature *)m_currentObject setLanguage:[attributes objectForKey:@"language"]];
		[m_data addObject:m_currentObject];
		[m_currentObject release];
	}
	[self clearCurrentString];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!m_currentStringValue)
	{
        m_currentStringValue = [[NSMutableString alloc] init];
    }
    [m_currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	elementName = [elementName lowercaseString];
	
	if ([elementName isEqualToString:@"stacktrace"])
	{
		LogMessage *logMessage = (LogMessage *)m_parentObject;
		NSDictionary *attributes = (NSDictionary *)m_currentObject;
		NSString *stackTraceIndex = (NSString *)[attributes objectForKey:@"index"];
		NSString *ignoreToIndex = (NSString *)[attributes objectForKey:@"ignoreToIndex"];
		NSString *language = (NSString *)[attributes objectForKey:@"language"];
		NSArray *stacktrace = [StackTraceParser parseStackTrace:m_currentStringValue 
			ofLanguageType:language];
		
		if (stackTraceIndex)
		{
			if ([stackTraceIndex intValue] >= 0 && [stackTraceIndex intValue] < [stacktrace count])
			{
				StackTraceItem *item = [stacktrace objectAtIndex:[stackTraceIndex intValue]];
				[logMessage setFQClassName:[item fqClassName]];
				[logMessage setMethod:[item method]];
				[logMessage setFile:[item file]];
				[logMessage setLine:[item line]];
			}
			else
			{
				NSLog(@"warning! stacktrace index is out of bounds");
			}
		}		
		if (ignoreToIndex)
		{
			if ([ignoreToIndex intValue] >= 0 && [ignoreToIndex intValue] < [stacktrace count])
			{
				stacktrace = [stacktrace subarrayWithRange:NSMakeRange([ignoreToIndex intValue] + 1, 
					[stacktrace count] - [ignoreToIndex intValue] - 1)];
			}
			else
			{
				NSLog(@"warning! stacktrace ignoreindex is out of bounds");
			}
		}		
		if ([stacktrace	count])
		{
			[(LogMessage *)logMessage setStacktrace:stacktrace];
		}			
		[m_currentObject release];
	}
	else if ([elementName isEqualToString:@"message"])
	{
		[(LogMessage *)m_parentObject setMessage:m_currentStringValue];
	}
	else if ([elementName isEqualToString:@"log"])
	{
		m_parentObject = nil;
	}
	
	[self clearCurrentString];
	m_currentObject = nil;
}

- (void)clearCurrentString
{
	[m_currentStringValue release];
    m_currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"parsing error at line %d, column %d: %@", [parser lineNumber], [parser columnNumber],
		parseError);
	[m_data release];
	m_data = nil;
}


@end
