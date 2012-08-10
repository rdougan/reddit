//
//  RDOutlineView.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDOutlineView.h"

@implementation RDOutlineView

- (void)awakeFromNib
{
    [[self enclosingScrollView] setDrawsBackground:NO];
    [[self enclosingScrollView] setBorderType:NSNoBorder];
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    // don't draw a background rect
}

@end
