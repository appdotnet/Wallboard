//
//  BrowserWindowController.m
//  Wallboard
//
//  Created by Bryan Berg on 11/17/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import "BrowserWindowController.h"

@interface BrowserWindowController ()

@end

@implementation BrowserWindowController

- (id)initWithScreenIndex:(NSUInteger)screenIndex {
    self = [super initWithWindowNibName:@"BrowserWindowController"];
    if (self) {
        self.screenIndex = screenIndex;
        self.screen = [[NSScreen screens] objectAtIndex:screenIndex];
    }

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    NSString *urlKey = [NSString stringWithFormat:@"url.%lu", self.screenIndex];
    self.webView.mainFrameURL = [[NSUserDefaults standardUserDefaults] objectForKey:urlKey];
}

- (void)setScreen:(NSScreen *)screen {
    _screen = screen;
    [self.window setLevel:CGShieldingWindowLevel()];
    [self.window setFrame:[screen frame] display:YES];
    [self.window orderWindow:NSWindowAbove relativeTo:[self.window.parentWindow windowNumber]];
}

@end
