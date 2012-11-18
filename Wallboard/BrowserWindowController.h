//
//  BrowserWindowController.h
//  Wallboard
//
//  Created by Bryan Berg on 11/17/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface BrowserWindowController : NSWindowController<NSWindowDelegate>

@property (nonatomic, assign) NSUInteger screenIndex;
@property (nonatomic, weak) NSScreen *screen;
@property (nonatomic, weak) IBOutlet WebView *webView;

- (id)initWithScreenIndex:(NSUInteger)screenIndex;

@end
