//
//  RDRKLink.h
//  RedditKit
//
//  Created by Robert Dougan on 8/5/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKRemoteManagedObject.h"

/**
 * This is the **Link** class which is an instance of a post in any subbreddit returned by the Reddit API.
 *
 * A link can be a number of types (RKLinkType):
 *
 * - RKLinkTypeImage - a image post
 * - RKLinkTypeVideo - a video post
 * - RKLinkTypeText - a text post
 * - RKLinkTypeURL - any other type of post witha  URL post
 */

@class RKSubreddit;

enum {
    RKLinkTypeImage,
    RKLinkTypeVideo,
    RKLinkTypeText,
    RKLinkTypeURL
};
typedef NSInteger RKLinkType;

@interface RKLink : RKRemoteManagedObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *permalink;
@property (nonatomic, strong) NSNumber *ups;
@property (nonatomic, strong) NSNumber *downs;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) RKSubreddit *subreddit;
@property (assign) RKLinkType type;

@end
