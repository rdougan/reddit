//
//  RDRKSubreddit.m
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKSubreddit.h"
#import "RKHTTPClient.h"

@interface RKSubreddit ()

@end

@implementation RKSubreddit

@dynamic url;
@dynamic title;
@dynamic subscribers;
@dynamic nsfw;
@dynamic capitalizedURL;

@dynamic links;

@synthesize before;
@synthesize after;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"Subreddit";
}

#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
    
	self.url = [dictionary objectForKey:@"url"];
	self.title = [dictionary objectForKey:@"title"];
	self.subscribers = [dictionary objectForKey:@"subscribers"];
	self.nsfw = [dictionary objectForKey:@"over18"];
    self.capitalizedURL = [[self.url substringWithRange:NSMakeRange(3, self.url.length - 4)] capitalizedString];
}

#pragma mark - Class methods

+ (void)subredditWithTitle:(NSString *)title withSuccess:(void (^)(RKSubreddit *subreddit))success failure:(void (^)(NSError *error))failure
{
    __block RKSubreddit *subreddit = [[self class] existingObjectWithKey:@"title" value:title];
    if (subreddit) {
        success(subreddit);
        return;
    }
    
    // Fetch it
    [[RKHTTPClient sharedClient] getSubredditWithTitle:title success:^(AFJSONRequestOperation *operation, id responseObject) {
        NSString *url = [[responseObject objectForKey:@"data"] objectForKey:@"url"];
        subreddit = [[self class] existingObjectWithKey:@"url" value:url];
        success(subreddit);
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)subredditWithURL:(NSString *)url withSuccess:(void (^)(RKSubreddit *subreddit))success failure:(void (^)(NSError *error))failure
{
    __block RKSubreddit *subreddit = [[self class] existingObjectWithKey:@"url" value:url];
    if (subreddit) {
        success(subreddit);
        return;
    }
    
    // Fetch it
    [[RKHTTPClient sharedClient] getSubredditWithURL:url success:^(AFJSONRequestOperation *operation, id responseObject) {
        NSString *cleanUrl = [[responseObject objectForKey:@"data"] objectForKey:@"url"];
        subreddit = [[self class] existingObjectWithKey:@"url" value:cleanUrl];
        success(subreddit);
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Links

- (void)getLinksWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    // Check if we need to load more or not
    if (self.after) {
        [[RKHTTPClient sharedClient] getMoreLinksForSubreddit:self success:^(AFJSONRequestOperation *operation, id responseObject) {
            if (success) {
                success();
            }
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } else {
        [[RKHTTPClient sharedClient] getLinksForSubreddit:self success:^(AFJSONRequestOperation *operation, id responseObject) {
            if (success) {
                success();
            }
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (NSArray *)sortedLinks
{
    return [self.links sortedArrayUsingDescriptors:[[self class] defaultSortDescriptors]];
}

- (NSArray *)sortedLinksOfType:(RKLinkType)type
{
    NSMutableSet *linksOfType = [[NSMutableSet alloc] init];
    
    for (RKLink *link in self.links) {
        if (link.type == type) {
            [linksOfType addObject:link];
        }
    }
    
    NSArray *sortedArray = [linksOfType sortedArrayUsingDescriptors:[[self class] defaultSortDescriptors]];
    
    return sortedArray;
}

- (void)clearLinks
{
    NSMutableSet *links = [[NSMutableSet alloc] initWithSet:self.links];
    [links removeAllObjects];
    self.links = links;
}

@end
