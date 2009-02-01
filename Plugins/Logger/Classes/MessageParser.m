//
//  MessageParser.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright 2007 nesiumdotcom. All rights reserved.
//

#import "MessageParser.h"


@interface MessageParser (Private)
- (void)parseXMLString:(NSString *)xmlString;
- (void)clearCurrentString;
@end


@implementation MessageParser

#pragma mark -
#pragma mark Initialization & deallocation

- (id)initWithXMLString:(NSString *)xmlString delegate:(id)delegate
{
	if (self = [super init])
	{
		m_delegate = delegate;
		[self parseXMLString:xmlString];
	}
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
		message.fullClassName = [attributes objectForKey:kAttributeNameClass];
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
		m_currentObject = m_parentObject = [[CommandMessage alloc] initWithAction: 
			[attributes objectForKey:@"action"] attributes:attributes];
		[m_data addObject:m_currentObject];
		[m_currentObject release];
	}
	else if ([elementName isEqualToString:kNodeNamePolicyFileRequest])
	{
		m_currentObject = [AbstractMessage messageWithType:kLPMessageTypePolicyRequest];
		[m_data addObject:m_currentObject];
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
	else if ([elementName isEqualToString:kNodeNameMenu])
	{
		NSMenu *menu = [[NSMenu alloc] init];
		NSMenuItem *menuItem = [[NSMenuItem alloc] init];
		[menuItem setTitle:[attributes objectForKey:@"title"]];
		[menuItem setSubmenu:menu];
		[menu release];
		
		if ([m_currentObject isKindOfClass:[CommandMessage class]])
		{
			CommandMessage *cmd = (CommandMessage *)m_currentObject;
			if (!cmd.data)
			{
				cmd.data = [NSMutableArray array];
			}
			[(NSMutableArray *)cmd.data addObject:menuItem];
		}
		else if ([m_currentObject isKindOfClass:[NSMenu class]])
		{
			NSMenu *parentMenu = (NSMenu *)m_currentObject;
			[parentMenu addItem:menuItem];
		}
		[menuItem release];
		[menu setAutoenablesItems:YES];
		m_currentObject = menu;
	}
	else if ([elementName isEqualToString:kNodeNameMenuItem])
	{
		NSMenuItem *menuItem = [[NSMenuItem alloc] init];
		[menuItem setTitle:[attributes objectForKey:@"title"]];
		if ([m_currentObject isKindOfClass:[CommandMessage class]])
		{
			if (![(CommandMessage *)m_currentObject data])
			{
				[(CommandMessage *)m_currentObject setData:[NSMutableArray array]];
			}
			NSMutableArray *data = (NSMutableArray *)[(CommandMessage *)m_currentObject data];
			[data addObject:menuItem];
		}
		else if ([m_currentObject isKindOfClass:[NSMenu class]])
		{
			NSMenu *menu = (NSMenu *)m_currentObject;
			[menu addItem:menuItem];
		}
		if ([m_delegate respondsToSelector:@selector(parser:didParseMenuItem:)])
		{
			[m_delegate parser:self didParseMenuItem:menuItem];
		}
		[menuItem release];
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
				logMessage.fullClassName = item.fullClassName;
				logMessage.method = item.method;
				logMessage.file = item.file;
				logMessage.line = item.line;
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
	else if ([elementName isEqualToString:kNodeNameCommand])
	{
		m_parentObject = nil;
	}
	else if ([elementName isEqualToString:kNodeNameMenuItem])
	{
		return;
	}
	else if ([elementName isEqualToString:kNodeNameMenu])
	{
		m_currentObject = [(NSMenu *)m_currentObject supermenu];
		if (!m_currentObject)
		{
			m_currentObject = m_parentObject;
		}
		return;
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



#pragma mark -



@implementation StackTraceParser

+ (NSArray *)parseStackTrace:(NSString *)stacktrace ofLanguageType:(NSString *)language
{
	if (language == nil)
	{
		language = @"as3";
	}
	return [StackTraceParser parseAS3StackTrace:stacktrace];
}

+ (NSArray *)parseAS3StackTrace:(NSString *)stacktrace
{
	NSMutableArray *stackItems = [NSMutableArray array];
	NSArray *lines = [stacktrace componentsSeparatedByString:@"\n"];
	for (int32_t i = 1; i < [lines count]; i++) // ignore first line
	{
		NSString *line = [[lines objectAtIndex:i] substringFromIndex:4]; // ignore @"\tat "
		NSString *className = nil, *package = nil, *method = nil, *file = nil, *lineNo = nil;
		NSRange firstBracketRange = [line rangeOfString:@"["];
		if (firstBracketRange.location != NSNotFound)
		{
			// movie was most likely compiled with verbose-stacktraces
			NSRange lastBracketRange = [line rangeOfString:@"]" options:NSBackwardsSearch];
			if (lastBracketRange.location != NSNotFound)
			{
				NSString *chunk = [line substringWithRange:(NSRange){firstBracketRange.location + 1, 
					lastBracketRange.location - firstBracketRange.location - 1}];
				NSRange colonRange = [chunk rangeOfString:@":" options:NSBackwardsSearch];
				if (colonRange.location != NSNotFound && colonRange.location < [chunk length] - 1)
				{
					file = [chunk substringToIndex:colonRange.location];
					lineNo = [chunk substringFromIndex:colonRange.location + 1];
				}
			}
			line = [line substringToIndex:firstBracketRange.location];
		}
		
		NSRange methodDividerRange = [line rangeOfString:@"/" options:NSBackwardsSearch];
		if (methodDividerRange.location == NSNotFound)
		{
			methodDividerRange = [line rangeOfString:@"$i" options:NSBackwardsSearch];
		}
		if (methodDividerRange.location != NSNotFound)
		{
			method = [line substringWithRange:(NSRange){methodDividerRange.location + 
				methodDividerRange.length, [line length] - methodDividerRange.location - 
				methodDividerRange.length - 2}]; // -2 = omit parantheses
			NSRange doubleColonRange = [method rangeOfString:@"::" options:NSBackwardsSearch];
			if (doubleColonRange.location != NSNotFound)
			{
				method = [method substringFromIndex:doubleColonRange.location + 2];
			}
			line = [line substringToIndex:methodDividerRange.location];
		}
		
		NSArray *classPackageParts = [line componentsSeparatedByString:@"::"];
		if ([classPackageParts count] == 1)
		{
			className = [classPackageParts objectAtIndex:0];
		}
		else
		{
			package = [classPackageParts objectAtIndex:0];
			className = [classPackageParts objectAtIndex:1];
		}
		
		if (className)
		{
			NSRange slashRange = [className rangeOfString:@"/"];
			if (slashRange.location != NSNotFound)
			{
				className = [className substringToIndex:slashRange.location];
			}
		
			if ([className length] > 2 && [[className substringFromIndex:[className length] - 2] 
				isEqualToString:@"()"])
			{
				className = [className substringToIndex:[className length] - 2];
			}
			else if ([className length] > 1 && [[className substringFromIndex:[className length] - 1]
				isEqualToString:@"$"])
			{
				className = [className substringToIndex:[className length] - 1];
			}
		}
		
		if (package)
		{
			NSRange asExtensionRange = [package rangeOfString:@".as$" options:NSBackwardsSearch];
			if (asExtensionRange.location != NSNotFound)
			{
				package = nil;
			}
		}
		
		NSMutableString *fqClassNameMutable = [NSMutableString string];
		if (package)
		{
			[fqClassNameMutable appendString:package];
			if (className)
			{
				[fqClassNameMutable appendString:@"."];
			}
		}
		if (className)
		{
			[fqClassNameMutable appendString:className];
		}
		NSString *fqClassName = [fqClassNameMutable copy];
		
		if (!method) // calls from constructor
		{
			method = className;
		}
		
		StackTraceItem *item = [[StackTraceItem alloc] init];
		item.fullClassName = fqClassName;
		item.method = method;
		item.file = file;
		item.line = [lineNo intValue];
		[stackItems addObject:item];
		[fqClassName release];
		[item release];
	}
	return stackItems;
}

@end
