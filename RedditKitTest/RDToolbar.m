//
//  RDToolbar.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDToolbar.h"

@implementation RDToolbar

@synthesize initialLocation;
@synthesize window;

#pragma mark - Draggable window

- (void)mouseDown:(NSEvent *)theEvent
{
    self.initialLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self.window frame];
    NSPoint newOrigin = windowFrame.origin;
    
    NSPoint currentLocation = [theEvent locationInWindow];
    newOrigin.x += (currentLocation.x - initialLocation.x);
    newOrigin.y += (currentLocation.y - initialLocation.y);
    
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    [self.window setFrameOrigin:newOrigin];
}

@end
