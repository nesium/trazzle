//
//  MessageParserTest.m
//  Trazzle
//
//  Created by Marc Bauer on 08.07.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "MessageParserTest.h"


@implementation MessageParserTest

- (void)testForWhitespaceElision
{
	NSString *message = @"<log level=\"\" line=\"0\" ts=\"null\" class=\"unknown\" method=\"unknown\" file=\"unknown\" encodehtml=\"true\">\n\
	<message>hello\n\
 world</message>\n\
	<stacktrace language=\"as3\" index=\"3\" ignoreToIndex=\"3\">Error\n\
	at StackTrace()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/trazzle/com/nesium/logging/TrazzleLogger.as:182]\n\
	at com.nesium.logging::TrazzleLogger/send()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/trazzle/com/nesium/logging/TrazzleLogger.as:46]\n\
	at com.nesium.logging::TrazzleLogger/log()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/trazzle/com/nesium/logging/TrazzleLogger.as:36]\n\
	at global/log()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/trazzle/log.as:5]\n\
	at com.nivea.sweepstake::SweepstakeApp/startApplication()[/Daten/Projekte/Fork/Nivea/Newsletter/src/com/nivea/sweepstake/SweepstakeApp.as:70]\n\
	at reprise.core::Application/initApplication()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/core/Application.as:138]\n\
	at reprise.core::Application/resource_complete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/core/Application.as:131]\n\
	at flash.events::EventDispatcher/dispatchEventFunction()\n\
	at flash.events::EventDispatcher/dispatchEvent()\n\
	at reprise.commands::AbstractAsynchronousCommand/notifyComplete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/AbstractAsynchronousCommand.as:97]\n\
	at reprise.commands::CompositeCommand/executeNext()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/CompositeCommand.as:175]\n\
	at reprise.external::ResourceLoader/executeNext()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/external/ResourceLoader.as:183]\n\
	at reprise.commands::CompositeCommand/command_complete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/CompositeCommand.as:151]\n\
	at flash.events::EventDispatcher/dispatchEventFunction()\n\
	at flash.events::EventDispatcher/dispatchEvent()\n\
	at reprise.css::CSS/parseCSS()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/css/CSS.as:526]\n\
	at reprise.css::CSS/loader_complete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/css/CSS.as:492]\n\
	at flash.events::EventDispatcher/dispatchEventFunction()\n\
	at flash.events::EventDispatcher/dispatchEvent()\n\
	at reprise.commands::AbstractAsynchronousCommand/notifyComplete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/AbstractAsynchronousCommand.as:97]\n\
	at reprise.commands::CompositeCommand/executeNext()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/CompositeCommand.as:175]\n\
	at reprise.external::ResourceLoader/executeNext()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/external/ResourceLoader.as:183]\n\
	at reprise.commands::CompositeCommand/command_complete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/commands/CompositeCommand.as:151]\n\
	at flash.events::EventDispatcher/dispatchEventFunction()\n\
	at flash.events::EventDispatcher/dispatchEvent()\n\
	at reprise.external::AbstractResource/notifyComplete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/external/AbstractResource.as:303]\n\
	at reprise.css::CSSImport/notifyComplete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/css/CSSImport.as:44]\n\
	at reprise.external::AbstractResource/onData()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/external/AbstractResource.as:254]\n\
	at reprise.external::FileResource/loader_complete()[/Daten/Projekte/Fork/Nivea/Newsletter/lib/reprise/reprise/external/FileResource.as:85]\n\
	at flash.events::EventDispatcher/dispatchEventFunction()\n\
	at flash.events::EventDispatcher/dispatchEvent()\n\
	at flash.net::URLLoader/onComplete()</stacktrace>\n\
</log>";
	
	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message];
	NSArray *messages = [parser data];
	GHAssertEquals((int)[messages count], 1, @"num messages should be 1 but is %d", [messages count]);
	LogMessage *parsedMessage = (LogMessage *)[messages objectAtIndex:0];
	GHAssertTrue([[parsedMessage message] isEqualToString:@"hello<br /> world"], @"message should be 'hello<br /> world' but is '%@'", [parsedMessage message]);
	[parsedMessage setEncodeHTML:NO];
	GHAssertTrue([[parsedMessage message] isEqualToString:@"hello\n world"], @"message should be 'hello\n world' but is '%@'", [parsedMessage message]);
	[parser release];
}

- (void)testFunnyChars
{
	NSString *message = @"<log level=\"\" line=\"0\" ts=\"null\" class=\"unknown\" method=\"unknown\" file=\"unknown\" encodehtml=\"true\">\n\
	<message><![CDATA[false,true,]]></message>\n\
	<stacktrace language=\"as3\" index=\"4\" ignoreToIndex=\"4\">Error\n\
	at StackTrace()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/com/nesium/logging/TrazzleLogger.as:196]\n\
	at com.nesium.logging::TrazzleLogger/send()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/com/nesium/logging/TrazzleLogger.as:48]\n\
	at com.nesium.logging::TrazzleLogger/log()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/com/nesium/logging/TrazzleLogger.as:38]\n\
	at global/log()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/lib/trazzle/log.as:5]\n\
	at com.nesium.as3demo::DemoApplication/keyDown()[/Users/mb/Desktop/Contexts/1_nesiumdotcom/content/AS3_Demo_project/src/com/nesium/as3demo/DemoApplication.as:55]</stacktrace>\n\
</log>";

	MessageParser *parser = [[MessageParser alloc] initWithXMLString:message];
	NSArray *messages = [parser data];
	GHAssertEquals((int)[messages count], 1, @"num messages should be 1 but is %d", [messages count]);
	LogMessage *parsedMessage = (LogMessage *)[messages objectAtIndex:0];
	GHAssertTrue([[parsedMessage method] isEqualToString:@"keyDown"], @"message should be keyDown but is '%@'", [parsedMessage method]);
	GHAssertTrue([[parsedMessage shortClassName] isEqualToString:@"DemoApplication"], @"message should be DemoApplication but is '%@'", [parsedMessage className]);
	[parser release];
}

@end