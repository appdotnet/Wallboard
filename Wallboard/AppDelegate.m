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
#import "RoutingHTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <WebKit/WebKit.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

id nilify(id arg) { return arg ? arg : [NSNull null]; }

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
                                                      [self refreshBrowserWindows];
    }];
}

- (void)refreshBrowserWindows {
    if ([self.browserWindowControllers count] != [[NSScreen screens] count]) {
        [self createBrowserWindows];
    } else {
        for (BrowserWindowController *controller in self.browserWindowControllers) {
            [controller refreshPosition];
        }
    }
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

#pragma mark -
#pragma mark HTTP stuff

- (void)wrapRequest:(RouteRequest *)request
           response:(RouteResponse *)response
         innerBlock:(id (^)(id requestData))innerBlock {
    id requestData;
    NSError *error;

    if ([request.method isEqualToString:@"POST"]) {
        requestData = [NSJSONSerialization JSONObjectWithData:[request body]
                                                      options:0
                                                        error:&error];
        if (error != nil) {
            NSLog(@"Invalid JSON data in POST: %@", [error description]);
            [response setStatusCode:400];
            return;
        }
    }

    id responseData;
    @try {
        responseData = innerBlock(requestData);
    }
    @catch (NSException *e) {
        NSLog(@"Error in post: %@", e);
        [response setStatusCode:500];
        return;
    }

    if (responseData) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error != nil) {
            NSLog(@"Error encoding JSON response: %@", error);
            [response setStatusCode:500];
            return;
        }

        [response respondWithData:data];
    }
}

- (NSDictionary *)jsonDictForScreenIndex:(NSUInteger)screenIndex {
    __block NSDictionary *returnValue = nil;

    // UGH, this is gross. gross gross gross.
    // Technically these are UI methods, so call them on the main thread
    // I'm unsure if this is actually necessary.
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSScreen *screen = [[NSScreen screens] objectAtIndex:screenIndex];
        BrowserWindowController *browserWindowController = [self.browserWindowControllers objectAtIndex:screenIndex];

        NSRect frame = [screen frame];

        returnValue = @{
            @"api_endpoint": [NSString stringWithFormat:@"/screens/%lu", screenIndex],
            @"height": @(frame.size.height),
            @"width": @(frame.size.width),
            @"saved_url": nilify([browserWindowController.savedURL absoluteString]),
            @"current_url": nilify([browserWindowController.currentURL absoluteString]),
        };
    });

    return returnValue;
}

- (void)startHTTPServer {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"disablehttp"] boolValue])
        return;

    self.httpServer = [[RoutingHTTPServer alloc] init];

    self.httpServer.type = @"_wallboard._tcp.";

    UInt16 port = [[[NSUserDefaults standardUserDefaults] objectForKey:@"httpport"] unsignedShortValue];
    if (port == 0) {
        port = 9244; // WALL
    }

    self.httpServer.port = port;

	// Serve files from our embedded Web folder
    // This will always be empty, but'll keep lots of error messages
    // from showing up in the logs complaining about a lack of doc root
	[self.httpServer setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]];

    [self.httpServer get:@"/screens" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self wrapRequest:request response:response innerBlock:^id(id requestData) {
            NSUInteger count = MIN([[NSScreen screens] count], [self.browserWindowControllers count]);

            NSMutableArray *objs = [NSMutableArray arrayWithCapacity:count];

            for (NSUInteger i = 0; i < count; i++) {
                [objs addObject:[self jsonDictForScreenIndex:i]];
            }

            return objs;
        }];
    }];

    [self.httpServer get:@"/screens/:screen_id" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self wrapRequest:request response:response innerBlock:^id(id requestData) {
            NSUInteger count = MIN([[NSScreen screens] count], [self.browserWindowControllers count]);
            NSUInteger screenIndex = [[request param:@"screen_id"] intValue];

            if (screenIndex >= count) {
                [response setStatusCode:404];
                return nil;
            }

            return [self jsonDictForScreenIndex:screenIndex];
        }];
    }];

    [self.httpServer post:@"/screens/:screen_id" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self wrapRequest:request response:response innerBlock:^id(id requestData) {
            // c/p'd from above
            NSUInteger count = MIN([[NSScreen screens] count], [self.browserWindowControllers count]);
            NSUInteger screenIndex = [[request param:@"screen_id"] intValue];

            if (screenIndex >= count) {
                [response setStatusCode:404];
                return nil;
            }

            NSURL *url = [NSURL URLWithString:[requestData objectForKey:@"url"]];

            // whitelist URLs to http/https
            if (!([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
                [response setStatusCode:400];
                NSLog(@"Attempted to set URL with invalid scheme: %@", [url absoluteString]);
                return nil;
            }

            BOOL save = [[requestData objectForKey:@"save"] boolValue];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[self.browserWindowControllers objectAtIndex:screenIndex] setURL:url save:save];
            });
            
            return [self jsonDictForScreenIndex:screenIndex];
        }];
    }];

    NSError *error;
    BOOL success = [self.httpServer start:&error];

    if (!success) {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}

@end
