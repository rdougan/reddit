//
//  RDContentToolbar.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDContentToolbar.h"

@implementation RDContentToolbar

@synthesize textView = _textView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSRect rect = self.bounds;
        rect.origin.y -= 8.0;
        
        _textView = [[NSTextField alloc] initWithFrame:rect];
        [_textView setEditable:NO];
        [_textView setDrawsBackground:NO];
        [_textView setBordered:NO];
        [_textView setAlignment:NSCenterTextAlignment];
        [_textView setFont:[NSFont systemFontOfSize:13.0]];
        [_textView setAutoresizingMask:NSViewWidthSizable];
        [[_textView cell] setBackgroundStyle:NSBackgroundStyleLight];
        [self addSubview:_textView];
        
        NSButton *fullscreenButton = [NSWindow standardWindowButton:NSWindowFullScreenButton forStyleMask:NSTitledWindowMask];
        [fullscreenButton setTarget:self];
        [fullscreenButton setAction:@selector(makeFullscreen:)];
        [fullscreenButton setAutoresizingMask:NSViewMinXMargin];
        
        NSRect fullscreenButtonFrame = fullscreenButton.frame;
        fullscreenButtonFrame.origin.y = (self.bounds.size.height - fullscreenButtonFrame.size.height) / 2 - 1.0; // not quite perfect
        fullscreenButtonFrame.origin.x = self.bounds.size.width - fullscreenButtonFrame.size.width - fullscreenButtonFrame.origin.y;
        [fullscreenButton setFrame:fullscreenButtonFrame];
        
        [self addSubview:fullscreenButton];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *pattern = [NSColor colorWithPatternImage:[NSImage imageNamed:@"content_toolbar_bg.png"]];
    [pattern setFill];
    NSRectFill(dirtyRect);
}

- (IBAction)makeFullscreen:(id)sender
{
    [self.window toggleFullScreen:self];
}

@end