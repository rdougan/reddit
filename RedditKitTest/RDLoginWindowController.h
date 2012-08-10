//
//  RDLoginWindowController.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/10/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RDLoginWindowController : NSWindowController {
    IBOutlet NSTextField *usernameField;
    IBOutlet NSSecureTextField *passwordField;
}

- (IBAction)login:(id)sender;

@end
