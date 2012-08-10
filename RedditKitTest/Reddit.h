//
//  Reddit.h
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reddit : NSObject

+ (Reddit *)sharedClient;

// Subreddits
- (RKSubreddit *)getSubreddit:(NSString *)title;
- (void)getRemoteSubreddit:(NSString *)title withSuccess:(void (^)(RKSubreddit *subreddit))success;

@end
