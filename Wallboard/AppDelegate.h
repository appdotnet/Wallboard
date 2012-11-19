//
//  AppDelegate.h
//  Wallboard
//
//  Created by Bryan Berg on 11/16/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BrowserWindowController;
@class RoutingHTTPServer;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSArray *browserWindowControllers;
@property (nonatomic, strong) RoutingHTTPServer *httpServer;

+ (AppDelegate *)sharedDelegate;

@end
