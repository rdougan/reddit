//
//  Reddit.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/7/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "Reddit.h"

@implementation Reddit

#pragma mark - Singleton

+ (Reddit *)sharedClient
{
    static Reddit *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

#pragma mark - Subreddits

- (RKSubreddit *)getSubreddit:(NSString *)title
{
    NSManagedObjectContext *context = [RKSubreddit mainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[RKSubreddit entityWithContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title = %@", title]];
    
    NSArray *array = [context executeFetchRequest:request error:nil];
    
    if (array && array.count == 0) {
        return nil;
    }
    
    RKSubreddit *subreddit = [array objectAtIndex:0];
    
    return subreddit;
}

- (void)getRemoteSubreddit:(NSString *)title withSuccess:(void (^)(RKSubreddit *subreddit))success {
    [[RKHTTPClient sharedClient] getSubreddit:title withSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
        success([self getSubreddit:title]);
    } failure:^(AFJSONRequestOperation *operation, id responseObject) {
        NSLog(@"failure");
    }];
}

@end
