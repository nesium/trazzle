//
//  IPInspectorWindowController.m
//  Inspector
//
//  Created by Marc Bauer on 10.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "IPInspectorWindowController.h"


@implementation IPInspectorWindowController

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super initWithWindowNibName:@"InspectorWindow"]){
		m_rootObject = nil;
	}
	return self;
}



#pragma mark -
#pragma mark Public methods

- (void)displayObject:(id)object{
	[m_rootObject release];
	m_rootObject = [[IPObjectWrapper alloc] initWithObject:object];
	[m_outlineView reloadData];
	[m_outlineView expandItem:m_rootObject];
	[self showWindow:self];
}



#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad{
	[self.window setLevel:NSNormalWindowLevel];
}

- (NSString *)windowFrameAutosaveName{
	return @"IPInspectorWindow";
}



#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
	if (item == nil)
		return m_rootObject;
	return [[(IPObjectWrapper *)item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
	return [(IPObjectWrapper *)item hasChildren];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
	if (item == nil)
		return 1;
	return [[(IPObjectWrapper *)item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
	objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
	if (item == m_rootObject && m_rootObject.name == nil){
		if ([[tableColumn identifier] isEqualToString:@"name"])
			return [m_rootObject objectClassName];
		return @"";
	}
	
	if ([[tableColumn identifier] isEqualToString:@"name"]){
		return [(IPObjectWrapper *)item name];
	}else if ([[tableColumn identifier] isEqualToString:@"value"]){
		return [(IPObjectWrapper *)item value];
	}else if ([[tableColumn identifier] isEqualToString:@"type"]){
		return [(IPObjectWrapper *)item objectClassName];
	}
	return @"";
}
@end



@interface IPObjectWrapper (Private)
- (void)_setObject:(id)object;
- (void)_createChildrenFromArray:(NSArray *)anArray;
- (void)_createChildrenFromDict:(NSDictionary *)aDict;
@end


@implementation IPObjectWrapper

@synthesize children=m_children, 
			objectClassName=m_objectClassName, 
			name=m_name, 
			value=m_value;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithObject:(id)object{
	if (self = [super init]){
		m_objectClassName = nil;
		m_children = nil;
		m_value = nil;
		[self _setObject:object];
	}
	return self;
}

- (void)dealloc{
	[m_objectClassName release];
	[m_children release];
	[m_value release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)hasChildren{
	return [m_children count] > 0;
}



#pragma mark -
#pragma mark Private methods

- (void)_setObject:(id)object{
	if ([object isMemberOfClass:[ASObject class]]){
		m_objectClassName = [[(ASObject *)object type] copy];
		[self _createChildrenFromDict:[(ASObject *)object properties]];
	}else if ([object isMemberOfClass:[FlexArrayCollection class]]){
		m_objectClassName = [@"ArrayCollection" retain];
		[self _createChildrenFromArray:[(FlexArrayCollection *)object source]];
	}else if ([object isMemberOfClass:[FlexObjectProxy class]]){
		m_objectClassName = [@"ObjectProxy" retain];
		m_value = [[IPObjectWrapper alloc] initWithObject:[(FlexObjectProxy *)object object]];
	}else if ([object isKindOfClass:[NSArray class]]){
		m_objectClassName = [@"Array" retain];
		[self _createChildrenFromArray:object];
	}else if ([object isKindOfClass:[NSDictionary class]]){
		m_objectClassName = [@"Object" retain];
		[self _createChildrenFromDict:object];
	}else if ([object isKindOfClass:[NSString class]]){
		m_objectClassName = [@"String" retain];
		m_value = [object copy];
	}else if ([[object className] isEqualToString:@"NSCFBoolean"]){
		m_objectClassName = [@"Boolean" retain];
		m_value = [([object boolValue] ? @"true" : @"false") retain];
	}else if ([object isKindOfClass:[NSNumber class]]){
		if (strcmp([object objCType], "f") == 0 || 
			strcmp([object objCType], "d") == 0){
			m_objectClassName = [@"Number" retain];
		}else{
			m_objectClassName = [@"Integer" retain];
		}
		m_value = [[(NSNumber *)object stringValue] copy];
	}else if ([object isKindOfClass:[NSDate class]]){
		m_objectClassName = [@"Date" retain];
		m_value = [[(NSDate *)object description] copy];
	}else if ([object isKindOfClass:[NSData class]]){
		m_objectClassName = [@"ByteArray" retain];
	}else if ([object isKindOfClass:[NSNull class]] || object == nil){
		m_objectClassName = [@"Null" retain];
		m_value = @"null";
	}else{
		m_objectClassName = [@"Unknown Type" retain];
	}
}

- (void)_createChildrenFromArray:(NSArray *)anArray{
	NSMutableArray *children = [NSMutableArray arrayWithCapacity:[anArray count]];
	for (NSUInteger i = 0; i < [anArray count]; i++){
		IPObjectWrapper *wrapper = [[IPObjectWrapper alloc] initWithObject:
			[anArray objectAtIndex:i]];
		wrapper.name = [[NSNumber numberWithInt:i] stringValue];
		[children addObject:wrapper];
		[wrapper release];
	}
	m_children = [children copy];
}

- (void)_createChildrenFromDict:(NSDictionary *)aDict{
	NSMutableArray *children = [NSMutableArray arrayWithCapacity:[aDict count]];
	for (NSString *key in aDict){
		IPObjectWrapper *wrapper = [[IPObjectWrapper alloc] initWithObject:[aDict objectForKey:key]];
		wrapper.name = key;
		[children addObject:wrapper];
		[wrapper release];
	}
	m_children = [children copy];
}
@end