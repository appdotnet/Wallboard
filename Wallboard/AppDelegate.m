//
//  AppDelegate.m
//  Wallboard
//
//  Created by Bryan Berg on 11/16/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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

@end
