//
//  RDWindow.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/6/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDWindow.h"
#import "RDWindowFrame.h"

#define kWindowPadding 0

@implementation RDWindow

@synthesize initialLocation;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	self = [super initWithContentRect:contentRect styleMask:NSResizableWindowMask backing:bufferingType defer:deferCreation];
	if (self) {
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
	}
	return self;
}

- (void)setContentSize:(NSSize)newSize
{
	NSSize sizeDelta = newSize;
	NSSize childBoundsSize = [childContentView bounds].size;
	sizeDelta.width -= childBoundsSize.width;
	sizeDelta.height -= childBoundsSize.height;
	
	RDWindowFrame *frameView = [super contentView];
	NSSize newFrameSize = [frameView bounds].size;
	newFrameSize.width += sizeDelta.width;
	newFrameSize.height += sizeDelta.height;
	
	[super setContentSize:newFrameSize];
}

- (void)setContentView:(NSView *)aView
{
	if ([childContentView isEqualTo:aView]) {
		return;
	}
	
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;
    
	RDWindowFrame *frameView = [super contentView];
	
	if (childContentView) {
		[childContentView removeFromSuperview];
	}
    
    if (!frameView) {
		frameView = [[RDWindowFrame alloc] initWithFrame:bounds];
		[super setContentView:frameView];
	}
    
	childContentView = aView;
	[childContentView setFrame:[self contentRectForFrameRect:bounds]];
	[childContentView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	[frameView addSubview:childContentView];
}

- (NSView *)contentView
{
	return childContentView;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	return YES;
}

- (void)awakeFromNib
{
    [self becomeFirstResponder];
}

#pragma mark - RDWindowDelegate

- (void)keyDown:(NSEvent *)theEvent
{
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(windowDidKeyDown:)]) {
        [[self delegate] performSelector:@selector(windowDidKeyDown:) withObject:theEvent];
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(windowDidKeyUp:)]) {
        [[self delegate] performSelector:@selector(windowDidKeyUp:) withObject:theEvent];
    }
}

- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
	windowFrame.origin = NSZeroPoint;
	return NSInsetRect(windowFrame, kWindowPadding, kWindowPadding);
}

+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect styleMask:(NSUInteger)windowStyle
{
	return NSInsetRect(windowContentRect, -kWindowPadding, -kWindowPadding);
}

@end
