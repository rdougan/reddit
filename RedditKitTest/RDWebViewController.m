//
//  RDWebViewController.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/6/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDWebViewController.h"

#import <WebKit/WebKit.h>
#import <RedditKit/RedditKit.h>

@interface RDWebViewController ()

@end

@implementation RDWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    RKLink *link = representedObject;
    
    if (link.url) {
        
        NSString *rawLocationString = [self.webView stringByEvaluatingJavaScriptFromString:@"location.href;"];
        
        if (![rawLocationString isEqualToString:link.url]) {
            NSLog(@"SET: \n\n%@\n%@", link.url, rawLocationString);
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link.url]]];
        }
    }
}

@end
