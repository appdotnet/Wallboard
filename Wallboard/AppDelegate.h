//
//  AppDelegate.h
//  Wallboard
//
//  Created by Bryan Berg on 11/16/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BrowserWindowController;
@class HTTPServer;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSArray *browserWindowControllers;
@property (nonatomic, strong) HTTPServer *httpServer;

+ (AppDelegate *)sharedDelegate;

@end
