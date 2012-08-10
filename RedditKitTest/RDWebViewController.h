//
//  RDWebViewController.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/6/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface RDWebViewController : NSViewController

@property (assign) IBOutlet WebView *webView;

@end
