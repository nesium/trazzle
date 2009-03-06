//
//  FileMonitor.m
//  Trazzle
//
//  Created by Marc Bauer on 10.09.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "FileMonitor.h"

static FileMonitor *g_sharedInstance;

@implementation FileMonitor

#pragma mark -
#pragma mark Initialization & Deallocation

+ (FileMonitor *)sharedMonitor
{
	return g_sharedInstance ?: [[self new] autorelease];
}

- (id)init
{
	if (g_sharedInstance)
	{
		[self release];
	}
	else if (self = g_sharedInstance = [[super init] retain])
	{
		m_observers = [[NSMutableDictionary alloc] init];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self 
			selector:@selector(watcher_fileDidChangeNotification:) 
			name:UKFileWatcherWriteNotification object:[UKKQueue sharedFileWatcher]];
	}
	return g_sharedInstance;
}

- (void)dealloc
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[m_observers release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)addObserver:(id <FileObserver>)observer forFileAtPath:(NSString *)path
{
	BOOL isDir;
	// if the path does not lead to a valid file do nothing at all
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || isDir)
	{
//		[[SystemModel sharedModel] broadcastSystemMessageWithString:
//			@"Could not monitor file %@, because it doesn't exist.", path];
		return;
	}
	NSMutableSet *observerList = [m_observers objectForKey:path];
	// no observers exist at all
	if (observerList == nil)
	{
		observerList = [[NSMutableSet alloc] init];
		[m_observers setObject:observerList forKey:path];
		[observerList release];
		// observe file (we're only interested in when the filecontents get changed)
		[[UKKQueue sharedFileWatcher] addPathToQueue:path notifyingAbout:UKKQueueNotifyAboutWrite];
//		[[SystemModel sharedModel] broadcastSystemMessageWithString:
//			@"Started monitoring file %@.", path];
	}
	else
	{
//		[[SystemModel sharedModel] broadcastSystemMessageWithString:
//			@"Already monitoring file %@.", path];
	}
	// NSSet adds the observer only if it's not already in there
	[observerList addObject:observer];
}

- (void)removeObserver:(id <FileObserver>)observer forFileAtPath:(NSString *)path
{
	NSMutableSet *observerList = [m_observers objectForKey:path];
	// the file was not observed before
	if (observerList == nil)
	{
		return;
	}
	// remove observer
	[observerList removeObject:observer];
	// if there are no observers any more, stop observing file
	if ([observerList count] == 0)
	{
//		[[SystemModel sharedModel] broadcastSystemMessageWithString:
//			@"Stopped monitoring file %@.", path];
		[m_observers removeObjectForKey:path];
		[[UKKQueue sharedFileWatcher] removePathFromQueue:path];
	}
}

- (void)removeObserver:(id <FileObserver>)observer
{
	NSEnumerator *observedPaths = [[m_observers allKeys] objectEnumerator];
	NSString *observedPath;
	while (observedPath = [observedPaths nextObject])
	{
		[self removeObserver:observer forFileAtPath:observedPath];
	}
}



#pragma mark -
#pragma mark UKKQueue notifications

- (void)watcher_fileDidChangeNotification:(NSNotification *)notification
{
	NSString *path = [[notification userInfo] objectForKey:@"path"];
	NSEnumerator *observerList = [(NSSet *)[m_observers objectForKey:path] objectEnumerator];
	id <FileObserver> observer;
	while (observer = [observerList nextObject])
	{
		[observer fileMonitor:self fileDidChangeAtPath:path];
	}
}

@end