//
//  RDSidebarContainer.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDSidebarContainer.h"
#import "RDSidebarToolbar.h"

@implementation RDSidebarContainer

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill(rect);
	
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:5.0f yRadius:5.0f];
    
	[[NSColor colorWithCalibratedRed:0.145 green:0.153 blue:0.169 alpha:1] set];
    [circlePath fill];
    [circlePath addClip];
    
    self.wantsLayer = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
}

@end
