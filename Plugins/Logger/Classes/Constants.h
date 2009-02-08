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
#define kNodeNameMenu @"menu"
#define kNodeNameMenuItem @"menuitem"

#define kAttributeNameLogLevel @"level"
#define kAttributeNameFile @"file"
#define kAttributeNameMethod @"method"
#define kAttributeNameClass @"class"
#define kAttributeNameTimestamp @"ts"
#define kAttributeNameLine @"line"
#define kAttributeNameEncodeHTML @"encodehtml"

#define kEventStatusItemClicked @"statusItemClicked"

typedef enum _WindowBehaviourMode
{
	WBMBringToTop,
	WBMKeepOnTopWhileConnected,
	WBMKeepAlwaysOnTop,
	WBMDoNothing
} WindowBehaviourMode;

#define kLastSelectedFilterKey @"LastSelectedFilter"
#define kFilteringEnabledKey @"FilteringEnabled"
#define kFilterFileExtension @"trazzleFilter"
#define kFilterName @"Name"
#define kFilterPredicate @"Predicate"
#define kFilterVersion @"Version"