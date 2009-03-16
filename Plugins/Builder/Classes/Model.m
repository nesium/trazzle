#import "Model.h"


@interface Model (Private)
- (void) setValue: (NSNumber *) value forFlagAtIndex: (unsigned int) index;
- (NSNumber *) valueForFlagAtIndex: (unsigned int) index;
- (NSArray *) compilerFlagsForKey: (NSString *) key;
- (NSString *) compilerFlagByValidatingExpression: (id) expression;
@end



@implementation Model


//--------------------------------------------------------------------------------------------------
//											Public methods
//--------------------------------------------------------------------------------------------------
- (id) initWithCompilerSettingsConfig: (NSArray *) config
{
	self = [super init];	
	m_compilerSettingsConfig = [config retain];
	m_data = [[NSMutableDictionary alloc] init];
	unsigned int i;
	NSArray *flags = m_compilerSettingsConfig;	
	for (i = 0; i < [flags count]; i++)
	{
		NSDictionary *item = [flags objectAtIndex: i];
		[self setValue: [item objectForKey: @"content"] atIndex: i];
	}	
	return self;
}

- (void) setValue: (id) value atIndex: (unsigned int) index
{	
	NSArray *flags = m_compilerSettingsConfig;	
	NSDictionary *setting = [flags objectAtIndex: index];
	NSString *dataType = [setting objectForKey: @"type"];

	
	if ([dataType isEqualToString: @"flag"])
	{
		[self setValue: value forFlagAtIndex: index];
		return;
	}
	else if ([dataType isEqualToString: @"list"])
	{
		NSArray *list = [setting objectForKey: @"list"];
		NSDictionary *listItem = [list objectAtIndex: [value intValue]];
		value = [listItem objectForKey: @"value"];
	}
	
	NSString *key = [setting objectForKey: @"key"];
	[m_data setObject: value forKey: key];
}

- (id) valueAtIndex: (unsigned int) index
{
	NSArray *flags = m_compilerSettingsConfig;	
	NSDictionary *setting = [flags objectAtIndex: index];
	NSString *dataType = [setting objectForKey: @"type"];
	NSString *key = [setting objectForKey: @"key"];
	NSString *value = [m_data objectForKey: key];
	
	if ([dataType isEqualToString: @"flag"])
	{
		return [self valueForFlagAtIndex: index];
	}
	else if ([dataType isEqualToString: @"list"])
	{
		NSArray *listItems = [setting objectForKey: @"list"];
		unsigned int i;
		for (i = 0; i < [listItems count]; i++)
		{
			NSDictionary *item = [listItems objectAtIndex: i];
			NSString *listItemValue = [item objectForKey: @"value"];
			if ([listItemValue isEqualToString: value])
			{
				return [NSNumber numberWithInt: i];
			}
		}
		return [NSNumber numberWithInt: 0];		
	}
	return value;
}

- (NSString *) compilerString
{
	NSMutableArray *compilerFlags = [[NSMutableArray alloc] init];
	NSEnumerator *keyEnum = [m_data keyEnumerator];
	NSString *key;
	id item;
	while (key = [keyEnum nextObject])
	{
		item = [m_data objectForKey: key];
		if ([item isKindOfClass: [NSDictionary class]])
		{
			NSEnumerator *collectionEnum = [item keyEnumerator];
			NSString *collectionKey;
			while (collectionKey = [collectionEnum nextObject])
			{
				[compilerFlags addObjectsFromArray: [self compilerFlagsForKey: collectionKey]];
			}
		}
		else
		{
			[compilerFlags addObjectsFromArray: [self compilerFlagsForKey: key]];
		}
	}
	NSLog(@"%@", [compilerFlags componentsJoinedByString: @" "]);
	return nil;
}

- (NSArray *) compilerFlagsForKey: (NSString *) key
{
	NSMutableArray *flags = [[[NSMutableArray alloc] init] autorelease];
	NSArray *flagsConfig = m_compilerSettingsConfig;
	unsigned int i;	
	for (i = 0; i < [flagsConfig count]; i++)
	{
		NSDictionary *rowData = [flagsConfig objectAtIndex: i];
		NSString *rowKey = [rowData objectForKey: @"key"];
		
		if (![rowKey isEqualToString: key])
		{
			continue;
		}
				
		NSString *dataType = [rowData objectForKey: @"type"];
		id compilerFlag = [rowData objectForKey: @"compilerValue"];
		id value;		
		if ([dataType isEqualToString: @"flag"])
		{
			value = [self valueForFlagAtIndex: i];
			if (compilerFlag == nil || ![value boolValue])
			{
				continue;
			}
			[flags addObject: compilerFlag];
			continue;
		}
		compilerFlag = [self compilerFlagByValidatingExpression: compilerFlag];
		value = [m_data objectForKey: key];
		if (compilerFlag == nil)
		{
			continue;
		}
		[flags addObject: [NSString stringWithFormat: compilerFlag, value]];
	}
	return flags;
}

- (NSString *) compilerFlagByValidatingExpression: (id) expression
{
	if ([expression isKindOfClass: [NSString class]])
	{
		return expression;
	}
	if (![expression isKindOfClass: [NSArray class]])
	{
		return nil;
	}
	
	unsigned int i;
	BOOL hadIfStatement = NO;
	for (i = 0; i < [expression count]; i++)
	{
		NSPredicate *predicate;
		BOOL predicateMatches = NO;
		NSDictionary *item = [expression objectAtIndex: i];
		NSString *statement = [[item objectForKey: @"statement"] lowercaseString];
		NSString *condition = [item objectForKey: @"condition"];		
		
		if ([statement isEqualToString: @"if"])
		{
			hadIfStatement = YES;
			predicate = [NSPredicate predicateWithFormat: condition];
			predicateMatches = [predicate evaluateWithObject: m_data];
		}
		else if ([statement isEqualToString: @"else if"])
		{
			if (!hadIfStatement)
			{
				continue;
			}
			predicate = [NSPredicate predicateWithFormat: condition];
			predicateMatches = [predicate evaluateWithObject: m_data];			
		}
		else if ([statement isEqualToString: @"else"])
		{
			if (!hadIfStatement)
			{
				continue;
			}			
			predicateMatches = YES;
		}
		
		NSString *value = [item objectForKey: @"value"];
		if (predicateMatches)
		{
			return value;
		}
	}
	return nil;
}



//--------------------------------------------------------------------------------------------------
//										Private methods
//--------------------------------------------------------------------------------------------------
- (void) setValue: (NSNumber *) value forFlagAtIndex: (unsigned int) index
{
	NSArray *flags = m_compilerSettingsConfig;
	NSDictionary *setting = [flags objectAtIndex: index];
	NSString *collectionKey = [setting objectForKey: @"collection"];
	NSString *key = [setting objectForKey: @"key"];
	NSMutableDictionary *collection;
	
	if ([m_data objectForKey: collectionKey] == nil)
	{
		collection = [NSMutableDictionary dictionary];
		[m_data setObject: collection forKey: collectionKey];
	}
	else
	{
		collection = [m_data objectForKey: collectionKey];
	}

	[collection setObject: [value stringValue] forKey: key];
}

- (NSNumber *) valueForFlagAtIndex: (unsigned int) index
{
	NSArray *flags = m_compilerSettingsConfig;	
	NSDictionary *setting = [flags objectAtIndex: index];
	NSString *collectionKey = [setting objectForKey: @"collection"];
	NSString *key = [setting objectForKey: @"key"];
	NSMutableDictionary *collection = [m_data objectForKey: collectionKey];
	return [NSNumber numberWithInt: [[collection objectForKey: key] intValue]];
}

@end