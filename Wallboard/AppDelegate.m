//
//  AppDelegate.m
//  Wallboard
//
//  Created by Bryan Berg on 11/16/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserWindowController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <WebKit/WebKit.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *)[NSApp delegate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self startHTTPServer];

    [self createBrowserWindows];
    [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidChangeScreenParametersNotification
                                                      object:NSApp queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self createBrowserWindows];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self destroyBrowserWindows];
}

- (void)createBrowserWindows {
    if (self.browserWindowControllers != nil) {
        [self destroyBrowserWindows];
    }
    
    NSUInteger screenCount = [[NSScreen screens] count];
    NSMutableArray *windowControllers = [NSMutableArray arrayWithCapacity:screenCount];

    for (NSUInteger i = 0; i < screenCount; i++) {
        [windowControllers addObject:[[BrowserWindowController alloc] initWithScreenIndex:i]];
    }

    // freeze to immutable array
    self.browserWindowControllers = [windowControllers copy];
}

- (void)destroyBrowserWindows {
    NSArray *windowControllers = self.browserWindowControllers;
    self.browserWindowControllers = nil;

    for (BrowserWindowController *browser in windowControllers) {
        [browser close];
    }
}

- (void)startHTTPServer {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"disablehttp"] boolValue])
        return;

	self.httpServer = [[HTTPServer alloc] init];

    //	[self.httpServer setConnectionClass:[MyHTTPConnection class]];

	[self.httpServer setType:@"_wallboard._tcp."];

    UInt16 port = [[[NSUserDefaults standardUserDefaults] objectForKey:@"httppport"] unsignedShortValue];
    if (port == 0) {
        port = 9244; // WALL
    }

    self.httpServer.port = port;

	// Serve files from our embedded Web folder
//	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
//	DDLogVerbose(@"Setting document root: %@", webPath);
//	[self.httpServer setDocumentRoot:webPath];

	NSError *error;
	BOOL success = [self.httpServer start:&error];

	if (!success) {
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

@end
