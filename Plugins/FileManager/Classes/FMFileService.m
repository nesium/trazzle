//
//  FileService.m
//  Logger
//
//  Created by Marc Bauer on 03.04.10.
//  Copyright 2010 nesiumdotcom. All rights reserved.
//

#import "FMFileService.h"

@interface FMFileService (Private)
- (NSDictionary *)_attributesForFileAtPath:(NSString *)aPath;
@end

@implementation FMFileService

- (NSDictionary *)gateway:(AMFRemoteGateway *)gateway browseForFile:(NSArray *)allowedExtensions{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSInteger result = [panel runModalForTypes:allowedExtensions];
	if (result != NSOKButton)
		return nil;
	NSString *path = [[panel filenames] objectAtIndex:0];
	return [self _attributesForFileAtPath:path];
}

- (NSData *)gateway:(AMFRemoteGateway *)gateway readContentsOfFile:(NSString *)aPath{
	NSError *error = nil;
	NSLog(@"path: %@", aPath);
	NSData *data = [NSData dataWithContentsOfFile:aPath options:0 error:&error];
	return data;
}



#pragma mark -
#pragma mark Private methods

- (NSDictionary *)_attributesForFileAtPath:(NSString *)aPath{
	NSError *error = nil;
	NSDictionary *allAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:aPath 
		error:&error];
	if (!allAttribs){
		NSLog(@"%@", error);
		return nil;
	}
	NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:
		aPath, @"path", 
		[allAttribs objectForKey:NSFileCreationDate], @"creationDate", 
		NSFileTypeForHFSTypeCode([[allAttribs objectForKey:NSFileHFSCreatorCode] unsignedLongValue]), 
			@"creator", 
		[aPath pathExtension], @"extension", 
		[allAttribs objectForKey:NSFileModificationDate], @"modificationDate", 
		[aPath lastPathComponent], @"name", 
		[allAttribs objectForKey:NSFileSize], @"size", 
		[aPath pathExtension], @"type", 
		nil];
	NSLog(@"attribs");
	return attribs;
}
@end