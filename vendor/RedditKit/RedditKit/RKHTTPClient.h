//
//  RDRKHTTPClient.h
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "AFNetworking.h"

/**
 * The main HTTP client which interacts with the Reddit API.
 */

typedef void (^RDRKHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^RDRKHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@class RKUser;
@class RKSubreddit;
@class RKLink;

@interface RKHTTPClient : AFHTTPClient

/**
 * @name Singleton
 */

/**
 * A shared instance of this HTTP Client.
 * @return a instance of RKHTTPClient
 */
+ (RKHTTPClient *)sharedClient;

/**
 * @name Authentication
 */

/**
 * Login to the Reddit API with a username, password, and option success and failure blocks.
 *
 * @param username The username of the user
 * @param password The password of the user
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(RDRKHTTPClientSuccess)success
                  failure:(RDRKHTTPClientFailure)failure;

/**
 * @name Subscriptions
 */

/**
 * Gets the list of subscriptions for a specified RKUser.
 *
 * @param user A instance of RKUser
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)getSubscriptionsWithUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Subscribes to a specified RKSubreddit
 *
 * @param subreddit A instance of RKSubreddit
 * @param user A instance of RKUser
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)subscribeToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Unsubscribes to a specified RKSubreddit
 *
 * @param subreddit A instance of RKSubreddit
 * @param user A instance of RKUser
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)unsubscribeToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * @name Voting
 */

/**
 * Upvotes a RKLink using a specified RKUser (normally the [RKUser currentUser]).
 * @param user A instance of RKUser
 * @param link A instance of RKLink
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)upVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Downvotes a RKLink using a specified RKUser (normally the [RKUser currentUser]).
 * @param user A instance of RKUser
 * @param link A instance of RKLink
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)downVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Removes a vote from a RKLink using a specified RKUser (normally the [RKUser currentUser]).
 * @param user A instance of RKUser
 * @param link A instance of RKLink
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)removeVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * @name Subreddits
 */

/**
 * Gets a requested subreddit from Reddit.
 *
 * @param title The title of the subreddit.
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)getSubredditWithTitle:(NSString *)title success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Gets a requested subreddit from Reddit.
 *
 * @param url The url of the subreddit.
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)getSubredditWithURL:(NSString *)url success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Gets the latest links for a RKSubreddit.
 *
 * @param subreddit The RKSubreddit to load the links on.
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)getLinksForSubreddit:(RKSubreddit *)subreddit success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

/**
 * Gets the more links for a RKSubreddit.
 *
 * @param subreddit The RKSubreddit to load the links on.
 * @param success The block to be called if the request succeeds (optional).
 * @param failure The block to be called if the request fails (optional).
 */
- (void)getMoreLinksForSubreddit:(RKSubreddit *)subreddit success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

@end
