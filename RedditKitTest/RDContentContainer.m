//
//  RDContentView.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDContentContainer.h"

@implementation RDContentContainer

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill(rect);

    self.wantsLayer = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
}

@end
