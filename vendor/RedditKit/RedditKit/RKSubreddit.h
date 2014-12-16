//
//  RDRKSubreddit.h
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKRemoteManagedObject.h"

#import "RKLink.h"

/**
 * A Reddit Subreddit.
 */

@interface RKSubreddit : RKRemoteManagedObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *subscribers;
@property (nonatomic, strong) NSNumber *nsfw;
@property (nonatomic, strong) NSString *capitalizedURL;

@property (nonatomic, strong) NSSet *links;

// Pagination
@property (nonatomic, strong) NSString *before;
@property (nonatomic, strong) NSString *after;

/**
 * @name Class methods
 */

/**
 * Finds a subreddit with a specified title.
 *
 * @param title The title of the subreddit to find.
 * @param success The block to be called if the find succeeds.
 * @param failure The block to be called if the find fails (optional).
 */
+ (void)subredditWithTitle:(NSString *)title withSuccess:(void (^)(RKSubreddit *subreddit))success failure:(void (^)(NSError *error))failure;

/**
 * Finds a subreddit with a specified URL.
 *
 * @param url The URL of the subreddit to find.
 * @param success The block to be called if the find succeeds.
 * @param failure The block to be called if the find fails (optional).
 */
+ (void)subredditWithURL:(NSString *)url withSuccess:(void (^)(RKSubreddit *subreddit))success failure:(void (^)(NSError *error))failure;

/**
 * Finds a subreddit with a specified URL.
 *
 * @param url The URL of the subreddit to find.
 * @param success The block to be called if the find succeeds.
 * @param failure The block to be called if the find fails (optional).
 */

- (void)getLinksWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 * Returns an array of sorted links.
 *
 * @return NSArray A sorted list of RKLinks.
 */
- (NSArray *)sortedLinks;

/**
 * Returns an array of sorted links of a certain RKLinkType
 *
 * @param type The RKLinkType to return.
 * @return NSArray A sorted list of RKLinks.
 */
- (NSArray *)sortedLinksOfType:(RKLinkType)type;

- (void)clearLinks;

/**
 * @name Helpers
 */

- (NSString *)capitalizedURL;

@end

@interface RKSubreddit (CoreDataGeneratedAccessors)
- (void)addLinksObject:(NSManagedObject *)value;
- (void)removeLinksObject:(NSManagedObject *)value;
- (void)addLinks:(NSSet *)value;
- (void)removeLinks:(NSSet *)value;
@end