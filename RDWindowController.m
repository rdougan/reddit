//
//  RDWindowController.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDWindowController.h"
#import "RDWebViewController.h"
#import "RDContentToolbar.h"

#define kRDRKImageFetchingLimit 10
#define COLUMNID_NAME @"NameColumn"

@interface RDWindowController ()
@property (assign) id initialSelectedObject;
@property (assign) int currentLoadedIndex;
@end

@implementation RDWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        linksDictionary = [NSMutableDictionary dictionary];
        
        dataSource = [NSArray arrayWithObjects:@"John", @"Mary", @"George", nil];
        
        expandedItems = [NSMutableArray new];
        
        data =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSMutableArray arrayWithObjects:@"Front page",@"Messages",nil],@"Dashboard",
                           [NSMutableArray arrayWithObjects:@"Technology",@"Science",@"Apple",nil],@"Subscriptions",nil];
        
        header = @"Header";
        child1 = @"Child 1";
        child2 = @"Child 2";
        child3 = @"Child 3";
    }
    
    return self;
}

- (void)awakeFromNib
{
//    [outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
//    RKSubreddit *subreddit = [[Reddit sharedClient] getSubreddit:@"funny"];
//    if (!subreddit) {
//        //            [self getRemoteSubreddit:@"funny" withSuccess:^(RDRKSubreddit *object) {
//        //                NSLog(@"subreddit: %@", object.title);
//        //
//        //                [[RDRKHTTPClient sharedClient] getLinksForSubreddit:object withSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
//        //    //                NSArray *links = [object sortedLinksOfType:RDRKLinkTypeImage];
//        //    //                [self.pageController setArrangedObjects:links];
//        //    //                [self fetchNextImagesWithIndex:0];
//        //                } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//        //                    NSLog(@"failure");
//        //                }];
//        //
//        //            }];
//    } else {
//        NSArray *links = [subreddit sortedLinksOfType:RKLinkTypeImage];
//        [pageController setArrangedObjects:links];
//        [self fetchNextImagesWithIndex:0];
//    }
}

#pragma mark - RDWindowDelegate methods

- (void)windowDidKeyDown:(NSEvent *)event
{
    switch([event keyCode]) {
        case 124:
            [pageController navigateForward:self];
            break;
        case 123:
            [pageController navigateBack:self];
            break;
        default:
            break;
    }
}

#pragma mark - NSPageControllerDelegate

- (NSString *)pageController:(NSPageController *)_pageController identifierForObject:(id)object
{
    RKLink *link = object;
    NSString *identifier = @"url";
    
    switch (link.type) {
        case RKLinkTypeImage:
            identifier = @"image";
            break;
            
        case RKLinkTypeVideo:
            identifier = @"video";
            break;
    }
    
    return identifier;
}

- (NSViewController *)pageController:(NSPageController *)_pageController viewControllerForIdentifier:(NSString *)identifier
{
    NSViewController *viewController;
    
    if ([identifier isEqualToString:@"image"]) {
        viewController = [[NSViewController alloc] initWithNibName:@"ImageView" bundle:nil];
    } else if ([identifier isEqualToString:@"video"]) {
        viewController = [[NSViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    } else {
        viewController = [[RDWebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    }
    
    return viewController;
}

-(void)pageController:(NSPageController *)_pageController prepareViewController:(NSViewController *)viewController withObject:(id)object
{
    RKLink *link = object;
    
    if (link) {
        viewController.representedObject = [linksDictionary objectForKey:link.remoteID];
        
        // Update the title in the content toolbar
        [contentToolbar.textView setStringValue:link.title];
        
        int index = (int)[[pageController arrangedObjects] indexOfObject:link];
        [self fetchNextImagesWithIndex:index];
    }
    
    // Reset magnification if it is an image
    if (link.type == RKLinkTypeImage) {
        BOOL isRepreparingOriginalView = (self.initialSelectedObject && self.initialSelectedObject == link) ? YES : NO;
        if (!isRepreparingOriginalView) {
            [(NSScrollView*)viewController.view setMagnification:1.0];
        }
    }
}

- (void)pageControllerWillStartLiveTransition:(NSPageController *)_pageController {
    self.initialSelectedObject = [pageController.arrangedObjects objectAtIndex:pageController.selectedIndex];
}

- (void)pageControllerDidEndLiveTransition:(NSPageController *)_pageController
{
    [pageController completeTransition];
}

#pragma mark - Image Loading

- (void)fetchNextImagesWithIndex:(int)index
{
    if (!self.currentLoadedIndex) {
        self.currentLoadedIndex = 0;
    } else if (index < (self.currentLoadedIndex - kRDRKImageFetchingLimit)) {
        return;
    }
    
    int newIndex;
    
    for (int i = 0; i < kRDRKImageFetchingLimit; i++) {
        newIndex = i + self.currentLoadedIndex;
        
        if ([[pageController arrangedObjects] count] > newIndex) {
            RKLink *link = [[pageController arrangedObjects] objectAtIndex:newIndex];
            if (link.type == RKLinkTypeImage) {
                [self loadLinkImage:link];
            }
        }
    }
    
    self.currentLoadedIndex = self.currentLoadedIndex + kRDRKImageFetchingLimit;
}

- (void)loadLinkImage:(RKLink *)link
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link.url]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^NSImage *(NSImage *image) {
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSImage *image) {
        [linksDictionary setObject:image forKey:link.remoteID];
        [self refreshActiveViewControllerForLink:link];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    [operationQueue addOperation:operation];
}

- (void)refreshActiveViewControllerForLink:(RKLink *)link
{
    if ([[pageController arrangedObjects] count] < [pageController selectedIndex]) {
        return;
    }
    
    RKLink *activeLink = [[pageController arrangedObjects] objectAtIndex:[pageController selectedIndex]];
    
    if (!activeLink || activeLink != link) {
        return;
    }
    
    NSViewController *viewController = [pageController selectedViewController];
    viewController.representedObject = [linksDictionary objectForKey:link.remoteID];
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    [cell setDrawsBackground:YES];
}

- (BOOL)outlineView:(NSOutlineView *)aOutlineView isItemExpandable:(id)item
{
    if ([self outlineView:aOutlineView numberOfChildrenOfItem:item] > 0)
    {
        return YES;
    }
    
    return NO;
}
- (BOOL)outlineView:(NSOutlineView *)aOutlineView shouldSelectItem:(id)item
{
    NSArray *exceptions = [data allKeys];
    
    if ([exceptions containsObject:item]) {
        return NO;
    }
    
//    [NSThread detachNewThreadSelector:@selector(willDisplayViewForItem:) toTarget:postSelectionController withObject:item];
    
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)aOutlineView shouldExpandItem:(id)item
{
    [expandedItems addObject:item];
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)aOutlineView shouldCollapseItem:(id)item
{
    if ([expandedItems containsObject:item]) {
        [expandedItems removeObject:item];
    }
    
    return YES;
}

#pragma mark - NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)aOutlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        // Root node, so we return the key for which index it requires
        return [[[data allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:index];
    } else {
        return [[data objectForKey:item] objectAtIndex:index];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)aOutlineView numberOfChildrenOfItem:(id)item
{
    if (!item) {
        return [[data allKeys] count];
    } else {
        return [[data objectForKey:item] count];
    }
}

- (NSView*)outlineView:(NSOutlineView *)aOutlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([[data objectForKey:item] isKindOfClass:[NSArray class]]) {
        // Then we are dealing with headers, e.g Subscription or Main.
        NSTableCellView * aView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        [[aView textField] setStringValue:item];
        return aView;
    }
    
    if ([item isKindOfClass:[NSString class]]) {
        // We are dealing with children of parents
        NSTableCellView * aView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        [[aView textField] setStringValue:item];
        return aView;
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)aOutlineView isGroupItem:(id)item
{
    return [self outlineView:aOutlineView isItemExpandable:item];
}

@end
