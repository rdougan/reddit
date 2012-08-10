//
//  RDAppDelegate.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "AppDelegate.h"

#import "RDWindowController.h"
#import "RDLoginWindowController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    windowController = [[RDWindowController alloc] initWithWindowNibName:@"RDWindowController"];
	[windowController showWindow:self];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:kRKCurrentUserChangedNotificationName object:nil];
    
    __block RKUser *currentUser = [RKUser currentUser];
    
    if (!currentUser) {
        loginwindowController = [[RDLoginWindowController alloc] initWithWindowNibName:@"RDLoginWindowController"];
        [loginwindowController showWindow:self];
        
        return;
        
//        NSLog(@"loginWithUsername");
//        [[RKHTTPClient sharedClient] loginWithUsername:@"rdougan" password:@"72779673" success:^(AFJSONRequestOperation *operation, id responseObject) {
//            currentUser = [RKUser currentUser];
//            NSLog(@"Authenticated!\n - name: %@\n - modhash: %@\n - cookie: %@", currentUser.name, currentUser.modhash, currentUser.cookie);
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            NSLog(@"Authentication failure: %@", error);
//        }];
    } else {
        return;
        
        NSLog(@"Authenticated!\n - name: %@\n - modhash: %@\n - cookie: %@\n", currentUser.name, currentUser.modhash, currentUser.cookie);
        
        [RKSubreddit subredditWithTitle:@"climbing" withSuccess:^(RKSubreddit *subreddit) {
            NSLog(@"subreddit found!\n");
            
            if (subreddit.links.count == 0) {
                NSLog(@"no links yet, loading some...");
                
                [subreddit getLinksWithSuccess:^{
                    NSLog(@"loaded links: %i", subreddit.links.count);
                    
                    NSLog(@"gonna try load some more...");
                    [subreddit getLinksWithSuccess:^{
                        NSLog(@"loaded more links: %i", subreddit.links.count);
                    } failure:^(NSError *error) {
                        NSLog(@"error loading more links: %@", error);
                    }];
                } failure:^(NSError *error) {
                    NSLog(@"error loading links: %@", error);
                }];
            } else {
                NSLog(@"found links: %i", subreddit.links.count);
                
//                NSLog(@"gonna try load some more...");
//                [subreddit getLinksWithSuccess:^{
//                    NSLog(@"loaded more links: %i", subreddit.links.count);
//                } failure:^(NSError *error) {
//                    NSLog(@"error loading more links: %@", error);
//                }];
            }
            
        } failure:^(NSError *error) {
            NSLog(@"failure: %@", error);
        }];
        
        // get subscriptions
//        [[RKHTTPClient sharedClient] getSubscriptionsWithUser:currentUser success:^(AFJSONRequestOperation *operation, id responseObject) {
//            NSLog(@"subscriptions: %i", currentUser.subscriptions.count);
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            NSLog(@"failure");
//        }];
    }
    
//    if (![[RKHTTPClient sharedClient] isAuthenticated]) {
//        NSLog(@"not authenticated");
//        [[RKHTTPClient sharedClient] loginWithUsername:@"rdougan" password:@"72779673" success:^(AFJSONRequestOperation *operation, id responseObject) {
//            NSLog(@"succes!");
//            
//            NSLog(@"authenticated!\n\n%@", [[Reddit sharedClient] getCurrentUser]);
//            
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            NSLog(@"failure:\n\n%@", error);
//        }];
//    } else {
//        RKUser *user = [[Reddit sharedClient] getCurrentUser];
//        
//        NSLog(@"authenticated!\n name:%@\n modhash: %@", user.name, user.modhash);
        
//        RKSubreddit *subreddit = [[Reddit sharedClient] getSubreddit:@"funny"];
//        RKLink *link = [[subreddit sortedLinks] objectAtIndex:0];
        
//        [[RKHTTPClient sharedClient] upVoteWithUser:user onLink:link success:^(AFJSONRequestOperation *operation, id responseObject) {
//            NSLog(@"succes");
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            NSLog(@"failure");
//        }];
        
//        [[Reddit sharedClient] getRemoteSubreddit:@"funny" withSuccess:^(RKSubreddit *subreddit) {
//            NSLog(@"subreddit: %@", subreddit);
//            
//            [[RKHTTPClient sharedClient] getLinksForSubreddit:subreddit withSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
//                NSLog(@"response: %@", responseObject);
//            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//                NSLog(@"failure");
//            }];
//        }];
        
//        [[RKHTTPClient sharedClient] getSubscriptionsWithUser:[[Reddit sharedClient] getCurrentUser] success:^(AFJSONRequestOperation *operation, id responseObject) {
//            NSLog(@"success: \n\n\n subscriptions count: %i", [[Reddit sharedClient] getCurrentUser].subscriptions.count);
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            NSLog(@"failure");
//        }];
        
//        return;
        
//        NSLog(@"getMeWithSuccess");
//        [[RKHTTPClient sharedClient] getMeWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
//            
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            
//        }];
        
//        [[RDRKHTTPClient sharedClient] logoutWithUsername:@"rdougan"];
//    }
}

- (void)userLoggedIn
{
    RKUser *currentUser = [RKUser currentUser];
    
    NSLog(@"Authenticated!\n - name: %@\n - modhash: %@\n - cookie: %@", currentUser.name, currentUser.modhash, currentUser.cookie);
}

@end;