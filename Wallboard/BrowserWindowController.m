//
//  BrowserWindowController.m
//  Wallboard
//
//  Created by Bryan Berg on 11/17/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.  
//

#import "BrowserWindowController.h"

@interface BrowserWindowController ()

@property (nonatomic, weak, readonly) NSString *preferenceKey;

@end

@implementation BrowserWindowController

- (id)initWithScreenIndex:(NSUInteger)screenIndex {
    self = [super initWithWindowNibName:@"BrowserWindowController"];
    if (self) {
        self.screenIndex = screenIndex;

        BOOL debugMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"devmode"] boolValue];

        if (!debugMode) {
            NSScreen *screen = [[NSScreen screens] objectAtIndex:screenIndex];
            [self.window setLevel:CGShieldingWindowLevel()];
            [self.window setFrame:[screen frame] display:YES];
        }

        [self.window orderWindow:NSWindowAbove relativeTo:[self.window.parentWindow windowNumber]];
    }

    return self;
}

- (NSString *)preferenceKey {
    return [NSString stringWithFormat:@"url.%lu", self.screenIndex];
}

- (NSURL *)savedURL {
    return [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:self.preferenceKey]];
}

- (NSURL *)currentURL {
    return [[[self.webView.mainFrame provisionalDataSource] request] URL];
}

- (void)setURL:(NSURL *)url save:(BOOL)save {
    if (save) {
        [[NSUserDefaults standardUserDefaults] setObject:[url absoluteString] forKey:self.preferenceKey];
    }

    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:self.savedURL]];
}

@end
