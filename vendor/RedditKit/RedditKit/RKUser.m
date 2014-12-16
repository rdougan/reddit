//
//  RKUser.m
//  RedditKit
//
//  Created by Robert Dougan on 8/9/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKUser.h"
#import "RKSubreddit.h"
#import "RKDefines.h"
#import "RKHTTPClient.h"

#import "SSKeychain.h"

static NSString *const kRKUserIDKey = @"RKUserID";
static RKUser *__currentUser = nil;

@implementation RKUser

@dynamic name;
@dynamic linkKarma;
@dynamic commentKarma;
@dynamic isMod;
@dynamic isGold;
@dynamic hasModMail;
@dynamic hasMail;
@dynamic modhash;

@dynamic subscriptions;
@synthesize subscriptionsAfter;

@synthesize cookie = _cookie;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"User";
}

#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
    
	self.name = [dictionary objectForKey:@"name"];
	self.linkKarma = [dictionary objectForKey:@"link_karma"];
	self.commentKarma = [dictionary objectForKey:@"comment_karma"];
	self.isMod = [dictionary objectForKey:@"is_mod"];
	self.isGold = [dictionary objectForKey:@"is_gold"];
	self.hasModMail = [dictionary objectForKey:@"has_mod_mail"];
	self.hasMail = [dictionary objectForKey:@"has_mail"];
	self.modhash = [dictionary objectForKey:@"modhash"];
}

#pragma mark - Singleton

+ (RKUser *)currentUser {
	if (!__currentUser) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *userID = [userDefaults objectForKey:kRKUserIDKey];
        
		if (!userID) {
			return nil;
		}
        
        NSString *cookie = [SSKeychain passwordForService:kRKKeychainService account:userID];
		if (!cookie) {
			return nil;
		}
        
		__currentUser = [self existingObjectWithRemoteID:userID];
        __currentUser.cookie = cookie;
        
        // Only post the notification if the name exists
        if (__currentUser.name) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRKCurrentUserChangedNotificationName object:__currentUser];
        }
	}
	return __currentUser;
}


+ (void)setCurrentUser:(RKUser *)user {
    if (__currentUser) {
		[SSKeychain deletePasswordForService:kRKKeychainService account:__currentUser.remoteID];
	}
    
	if (!user.remoteID) {
		__currentUser = nil;
		return;
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:user.remoteID forKey:kRKUserIDKey];
	[userDefaults synchronize];
	
    [SSKeychain setPassword:user.cookie forService:kRKKeychainService account:user.remoteID];
    
	__currentUser = user;
    
    // Only post the notification if the name exists
    if (user.name) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRKCurrentUserChangedNotificationName object:user];
    }
}

- (void)setRemoteID:(NSString *)remoteID
{
    // If the remoteID changes, we should update the keychain name.
    if (remoteID && ![remoteID isEqualToString:self.remoteID]) {
		if (self.cookie) {
            [SSKeychain deletePasswordForService:kRKKeychainService account:self.remoteID];
            [SSKeychain setPassword:self.cookie forService:kRKKeychainService account:remoteID];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:remoteID forKey:kRKUserIDKey];
            [userDefaults synchronize];
            
            // Only post the notification if the name exists
            if (self.name) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRKCurrentUserChangedNotificationName object:self];
            }
		}
    }
    
    [self setPrimitiveValue:remoteID forKey:@"remoteID"];
}

#pragma mark - Subscriptions

- (void)getSubscriptionsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [[RKHTTPClient sharedClient] getSubscriptionsWithUser:self success:^(AFJSONRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)subscribeToSubreddit:(RKSubreddit *)subreddit withSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [[RKHTTPClient sharedClient] subscribeToSubreddit:subreddit withUser:self success:^(AFJSONRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end
