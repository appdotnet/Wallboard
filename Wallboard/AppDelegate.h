//
//  AppDelegate.h
//  Wallboard
//
//  Created by Bryan Berg on 11/16/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSArray *browserWindowControllers;

@end
