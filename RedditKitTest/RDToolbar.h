//
//  RDToolbar.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RDToolbar : NSView {
    NSPoint initialLocation;
}

@property (assign) NSPoint initialLocation;
@property (retain) IBOutlet NSWindow *window;

@end
