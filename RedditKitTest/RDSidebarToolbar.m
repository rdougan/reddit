//
//  RDSidebarToolbar.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDSidebarToolbar.h"

@implementation RDSidebarToolbar

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:self.window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidResignMainNotification object:self.window];

        closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSTitledWindowMask];
        NSRect closeButtonRect = NSMakeRect(0, (self.bounds.size.height - closeButton.frame.size.height) / 2, closeButton.frame.size.width, closeButton.frame.size.height);
        closeButtonRect.origin.x = closeButtonRect.origin.y;
        [closeButton setFrame:closeButtonRect];
        [self addSubview:closeButton];
        
        miniaturizeButton = [NSWindow standardWindowButton:NSWindowMiniaturizeButton forStyleMask:NSTitledWindowMask];
        NSRect miniaturizeButtonRect = closeButtonRect;
        miniaturizeButtonRect.origin.x = closeButtonRect.origin.x + closeButtonRect.size.width + 5.0;
        [miniaturizeButton setFrame:miniaturizeButtonRect];
        [self addSubview:miniaturizeButton];
        
        maximizeButton = [NSWindow standardWindowButton:NSWindowZoomButton forStyleMask:NSTitledWindowMask];
        NSRect maximizeButtonRect = closeButtonRect;
        maximizeButtonRect.origin.x = miniaturizeButtonRect.origin.x + miniaturizeButtonRect.size.width + 5.0;
        [maximizeButton setFrame:maximizeButtonRect];
        [self addSubview:maximizeButton];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *pattern = [NSColor colorWithPatternImage:[NSImage imageNamed:@"sidebar_toolbar_bg.png"]];
    [pattern setFill];
    NSRectFill(dirtyRect);
}

#pragma mark - NSWindow

- (void)mainWindowChanged:(NSNotification *)aNotification
{
    [closeButton setNeedsDisplay];
    [miniaturizeButton setNeedsDisplay];
    [maximizeButton setNeedsDisplay];
}

@end
