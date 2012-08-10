//
//  RDWindow.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/6/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RDWindow : NSWindow {
    NSView *childContentView;
	NSButton *closeButton;
    NSPoint initialLocation;
}

@property (assign) NSPoint initialLocation;

@end

@protocol RDWindowDelegate <NSWindowDelegate>
@optional
- (void)windowDidKeyDown:(NSEvent *)theEvent;
- (void)windowDidKeyUp:(NSEvent *)theEvent;
@end