//
//  RDAppDelegate.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDWindowController;
@class RDLoginWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    RDWindowController *windowController;
    RDLoginWindowController *loginwindowController;
}

@end
