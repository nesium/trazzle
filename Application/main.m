//
//  main.m
//  Trazzle
//
//  Created by Marc Bauer on 24.11.07.
//  Copyright nesiumdotcom 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef DEBUG
void SWLog(NSString *format, id sender, SEL cmd, ...);
void SWLog(NSString *format, id sender, SEL cmd, ...)
{
	va_list args;
	va_start(args, cmd);
	format = [NSString stringWithFormat: @"[%@ (0x%lx)] %@ %@", 
		[sender className], (unsigned long)sender, NSStringFromSelector(cmd), format];
	NSLogv(format, args);
}
#else
inline void SWLog(NSString *format, id sender, SEL cmd, ...) {}
#endif


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