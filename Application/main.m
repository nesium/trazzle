//
//  main.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright nesiumdotcom 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

void handleSIGPIPE(int signal)
{
	char *string = "\n\nSIGPIPE occurred!\n\n";
	write(STDOUT_FILENO, string, strlen(string));
}


int main(int argc, char *argv[])
{
	(void) signal(SIGPIPE, handleSIGPIPE);
	
	sigset_t signalMask, oldSignalMask;
	sigemptyset(&signalMask);
	sigaddset(&signalMask, SIGPIPE);
	sigprocmask(SIG_BLOCK, &signalMask, &oldSignalMask);
		
    return NSApplicationMain(argc, (const char **) argv);
}