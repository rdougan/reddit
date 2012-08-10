//
//  RDWindowFrame.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/6/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDWindowFrame.h"
#import "RDSidebarContainer.h"
#import "RDContentContainer.h"

@implementation RDWindowFrame

//- (id)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
////        // Sidebar
////        RDSidebarContainer *sideBar = [[RDSidebarContainer alloc] initWithFrame:NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, 160.0, self.bounds.size.height)];
////        [sideBar setAutoresizingMask:NSViewHeightSizable|NSViewMaxXMargin];
////        [self addSubview:sideBar];
////        
////        // Content
////        RDContentContainer *content = [[RDContentContainer alloc] initWithFrame:NSMakeRect(160.0, self.bounds.origin.y, self.bounds.size.width - 160.0, self.bounds.size.height)];
////        [content setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMaxXMargin];
////        [self addSubview:content];
//    }
//    return self;
//}

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill(rect);
	
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:5.0f yRadius:5.0f];
    
	[[NSColor colorWithCalibratedRed:0.145 green:0.153 blue:0.169 alpha:1] set];
    [circlePath fill];
    [circlePath addClip];
}

@end
