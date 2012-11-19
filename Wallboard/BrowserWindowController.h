//
//  BrowserWindowController.h
//  Wallboard
//
//  Created by Bryan Berg on 11/17/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface BrowserWindowController : NSWindowController<NSWindowDelegate> {
    NSURL *_url;
}

@property (nonatomic, assign) NSUInteger screenIndex;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, readonly) NSURL *savedURL;
@property (nonatomic, readonly) NSURL *currentURL;

- (id)initWithScreenIndex:(NSUInteger)screenIndex;
- (void)setURL:(NSURL *)url save:(BOOL)save;

@end
