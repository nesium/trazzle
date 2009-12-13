/*
 *  Constants.h
 *  Logger
 *
 *  Created by Marc Bauer on 21.10.08.
 *  Copyright 2008 nesiumdotcom. All rights reserved.
 *
 */

#define kNodeNameLogMessage @"log"
#define kNodeNameMessage @"message"
#define kNodeNameStacktrace @"stacktrace"
#define kNodeNameCommand @"cmd"
#define kNodeNamePolicyFileRequest @"policy-file-request"
#define kNodeNameSignature @"signature"

#define kAttributeNameLogLevel @"level"
#define kAttributeNameFile @"file"
#define kAttributeNameMethod @"method"
#define kAttributeNameClass @"class"
#define kAttributeNameTimestamp @"ts"
#define kAttributeNameLine @"line"
#define kAttributeNameEncodeHTML @"encodehtml"

#define kEventStatusItemClicked @"statusItemClicked"

typedef enum _WindowBehaviourMode{
	WBMBringToTop = 1,
	WBMDoNothing = 2
} WindowBehaviourMode;

typedef enum _TabBehaviourMode{
	kTabBehaviourOneForAll = 1, 
	kTabBehaviourOneForSameURL = 2, 
	kTabBehaviourOneForEach = 3
} TabBehaviourMode;

#define kLastSelectedFilterKey @"LPLastSelectedFilter"
#define kFilteringEnabledKey @"LPFilteringEnabled"
#define kShowFlashLogMessages @"LPShowFlashlogMessages"
#define kKeepAlwaysOnTop @"LPKeepAlwaysOnTop"
#define kTabBehaviour @"LPTabBehaviour"
#define kReuseTabs @"LPReuseTabs"
#define kWindowBehaviour @"LPWindowBehaviour"
#define kKeepWindowOnTopWhileConnected @"LPKeepWindowOnTopWhileConnected" 
#define kClearMessagesOnNewConnection @"LPClearMessagesOnNewConnection"
#define kClearFlashLogMessagesOnNewConnection @"LPClearFlashLogMessagesOnNewConnection" 
#define kAutoSelectNewTab @"LPAutoSelectNewTab"
#define kShowTextMateLinks @"LPShowTextMateLinks"

#define kFilterFileExtension @"trazzleFilter"
#define kFilterName @"Name"
#define kFilterPredicate @"Predicate"
#define kFilterVersion @"Version"