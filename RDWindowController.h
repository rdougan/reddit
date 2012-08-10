//
//  RDWindowController.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RDWindow.h"

@class RDContentToolbar;

@interface RDWindowController : NSWindowController <NSPageControllerDelegate, RDWindowDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    // Sidebar
    IBOutlet NSOutlineView *outlineView;
    
    // Content
    IBOutlet NSPageController *pageController;
    IBOutlet RDContentToolbar *contentToolbar;
    
    NSOperationQueue *operationQueue;
    NSMutableDictionary *linksDictionary;
    
    NSString *header;
    NSString *child1;
    NSString *child2;
    NSString *child3;
    
    NSArray *dataSource;
    
    NSMutableDictionary *data;
    NSMutableArray *expandedItems;
}

@end
