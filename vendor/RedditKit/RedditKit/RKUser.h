//
//  RKUser.h
//  RedditKit
//
//  Created by Robert Dougan on 8/9/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKRemoteMAnagedObject.h"

@class RKSubreddit;

/**
 * A Reddit user.
 */

extern NSString *const kRKCurrentUserChangedNotificationName;

@interface RKUser : RKRemoteManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *linkKarma;
@property (nonatomic, strong) NSNumber *commentKarma;
@property (nonatomic, strong) NSNumber *isMod;
@property (nonatomic, strong) NSNumber *isGold;
@property (nonatomic, strong) NSNumber *hasModMail;
@property (nonatomic, strong) NSNumber *hasMail;
@property (nonatomic, strong) NSString *modhash;

@property (nonatomic, strong) NSSet *subscriptions;
@property (nonatomic, strong) NSString *subscriptionsAfter;


@property (nonatomic, strong) NSString *cookie;

/**
 * @name Singleton
 */

/**
 * The current logged in RKUser.
 *
 * @return a instance of RKUser
 */
+ (RKUser *)currentUser;

/**
 * Sets the [RKUser currentUser].
 *
 * @param user The new logged in RKUser.
 */
+ (void)setCurrentUser:(RKUser *)user;

- (void)getSubscriptionsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)subscribeToSubreddit:(RKSubreddit *)subreddit withSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

@end

@interface RKUser (CoreDataGeneratedAccessors)
- (void)addSubscriptionsObject:(NSManagedObject *)value;
- (void)removeSubscriptionsObject:(NSManagedObject *)value;
- (void)addSubscriptions:(NSSet *)value;
- (void)removeSubscriptions:(NSSet *)value;
@end
