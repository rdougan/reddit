//
//  RDLoginWindowController.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/10/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDLoginWindowController.h"

#import <QuartzCore/CoreAnimation.h>

@interface RDLoginWindowController ()
- (void)shakeWindow;
- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame;
@end

@implementation RDLoginWindowController

//- (id)initWithWindow:(NSWindow *)window
//{
//    self = [super initWithWindow:window];
//    if (self) {
//        // Initialization code here.
//    }
//    
//    return self;
//}

//- (void)windowDidLoad
//{
//    [super windowDidLoad];
//    
//    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//}

- (IBAction)login:(id)sender
{
    // Check for empty fields
    NSString *username = [usernameField stringValue];
    NSString *password = [passwordField stringValue];
    
    if (!username || username.length == 0) {
        [usernameField becomeFirstResponder];
        [self shakeWindow];
        return;
    }
    
    if (!password || password.length == 0) {
        [passwordField becomeFirstResponder];
        [self shakeWindow];
        return;
    }
    
    [usernameField setEnabled:NO];
    [passwordField setEnabled:NO];
    
    // Attempt to login
    [[RKHTTPClient sharedClient] loginWithUsername:username password:password success:^(AFJSONRequestOperation *operation, id responseObject) {
        [usernameField setEnabled:YES];
        [passwordField setEnabled:YES];
        
        [self.window close];
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        [self shakeWindow];
        
        [usernameField setEnabled:YES];
        [passwordField setEnabled:YES];
    }];
}

- (void)shakeWindow
{
    [self.window setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:[self.window frame]] forKey:@"frameOrigin"]];
	[[self.window animator] setFrameOrigin:[self.window frame].origin];
}

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    int numberOfShakes = 4;
    float durationOfShake = 0.5f;
    float vigourOfShake = 0.05f;
    
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < numberOfShakes; ++index) {
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}

@end
