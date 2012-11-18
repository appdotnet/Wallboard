//
//  BorderlessWindow.m
//  Wallboard
//
//  Created by Bryan Berg on 11/18/12.
//  Copyright (c) 2012 Mixed Media Labs, Inc. All rights reserved.
//

#import "BorderlessWindow.h"

@implementation BorderlessWindow

- (id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle
                   backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    return [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask
                              backing:bufferingType defer:flag];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
