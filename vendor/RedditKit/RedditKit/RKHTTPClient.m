//
//  RDRKHTTPClient.m
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "SSKeychain.h"

#import "RKHTTPClient.h"
#import "RKUser.h"
#import "RKSubreddit.h"
#import "RKLink.h"
#import "RKDefines.h"

#import "NSDictionary+QueryString.h"

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@interface RKHTTPClient ()
#pragma mark - Voting
- (void)voteWithUser:(RKUser *)user onLink:(RKLink *)link withDirection:(NSString *)direction success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

#pragma mark - Authentication helpers
- (NSMutableURLRequest *)authenticatedRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters;
- (void)getAuthenticatedPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postAuthenticatedPath:(NSString *)path
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - Users
- (void)getMeWithSuccess:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;

#pragma mark - Subscriptions
- (void)adjustSubscriptionToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user withAction:(NSString *)action success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure;
@end

@implementation RKHTTPClient {
    dispatch_queue_t _callbackQueue;
}

#pragma mark - Singleton

+ (RKHTTPClient *)sharedClient
{
    static RKHTTPClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

#pragma mark - NSObject

- (id)init {
    NSURL *base = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kRKURLScheme, kRKURLDomain]];
    
#ifndef NDEBUG
//	base = [NSURL URLWithString:@"http://localhost:9393"];
#endif
	
	if ((self = [super initWithBaseURL:base])) {
		// Use JSON
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"User-Agent" value:@"(JSON) Reddit API Ojective-C Wrapper by Robert Dougan"];

        _callbackQueue = dispatch_queue_create("com.rdougan.redditkit.network-callback-queue", 0);
	}
	return self;
}

//- (void)dealloc {
//	dispatch_release(_callbackQueue);
//}

#pragma mark - AFHTTPClient

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
	operation.successCallbackQueue = _callbackQueue;
	operation.failureCallbackQueue = _callbackQueue;
	[super enqueueHTTPRequestOperation:operation];
}

#pragma mark - Authentication

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"api/login/rdougan" parameters:nil];
    [request setHTTPMethod:@"POST"];
    
    NSData *requestBody = [[NSString stringWithFormat:@"api_type=json&user=%@&passwd=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBody];
    
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = [NSError errorWithDomain:kRKErrorDomain code:kRKErrorUnknown userInfo:nil];
        
        // Check for any errors
        NSArray *errors = [responseObject valueForKeyPath:@"json.errors"];
        if (errors.count) {
            NSArray *firstError = [errors objectAtIndex:0];
            if (firstError) {
                NSString *errorName = [firstError objectAtIndex:0];
                if ([errorName isEqualToString:@"RATELIMIT"]) {
                    error = [NSError errorWithDomain:kRKErrorDomain code:kRKErrorRateLimit userInfo:nil];
                } else if ([errorName isEqualToString:@"WRONG_PASSWORD"]) {
                    error = [NSError errorWithDomain:kRKErrorDomain code:kRKErrorWrongPassword userInfo:nil];
                }
            }
            
            failure((AFJSONRequestOperation *)operation, error);
            return;
        }
        
        // Success! get the modhash
        NSString *hash = [responseObject valueForKeyPath:@"json.data.modhash"];
        if (!hash || [hash isEqualToString:@""]) {
            // No modhash found
            failure((AFJSONRequestOperation *)operation, error);
            return;
        }
        
        // Get the cookie
        NSString *cookie = [responseObject valueForKeyPath:@"json.data.cookie"];
        if (!cookie || [cookie isEqualToString:@""]) {
            // No cookie found
            failure((AFJSONRequestOperation *)operation, error);
            return;
        }
        
        __weak NSManagedObjectContext *context = [RKUser mainContext];
        [context performBlockAndWait:^{
            RKUser *user = [RKUser objectWithDictionary:[NSDictionary dictionaryWithObject:@"__local" forKey:@"id"]];
            user.cookie = cookie;
            [user save];
            [RKUser setCurrentUser:user];
        }];
        
        // Get the user information
        [self getMeWithSuccess:^(AFJSONRequestOperation *meOperation, id meResponseObject) {
            if (success) {
                success((AFJSONRequestOperation *)meOperation, meResponseObject);
            }
        } failure:^(AFJSONRequestOperation *meOperation, NSError *meError) {
            if (failure) {
                failure((AFJSONRequestOperation *)meOperation, meError);
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Authenticated method helpers

- (NSMutableURLRequest *)authenticatedRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
{
    RKUser *user = [RKUser currentUser];
    if (!user) {
        return nil;
    }
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @".reddit.com", NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath,
                                @"reddit_session", NSHTTPCookieName,
                                user.cookie, NSHTTPCookieValue,
                                nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSArray *cookieArray = [NSArray arrayWithObjects:cookie, nil];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setAllHTTPHeaderFields:headers];
    
    return request;
}

- (void)getAuthenticatedPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self authenticatedRequestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postAuthenticatedPath:(NSString *)path
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self authenticatedRequestWithMethod:@"POST" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Users

- (void)getMeWithSuccess:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self getAuthenticatedPath:@"api/me.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [RKUser mainContext];
        [context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject valueForKeyPath:@"data"];

            RKUser *user = [RKUser currentUser];
            [user unpackDictionary:dataObject];
            user.remoteID = [dataObject objectForKey:@"id"];
            [user save];
        }];
        
        if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
}

#pragma mark - Subscriptions

- (void)getSubscriptionsWithUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    // Check for user
    if (!user) {
        failure(nil, nil);
    }
    
    [self getAuthenticatedPath:@"reddits/mine/subscriber.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [RKUser mainContext];
		[context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject objectForKey:@"data"];
            
            NSDictionary *childrenArray = [dataObject objectForKey:@"children"];
            for (NSDictionary *subredditObject in childrenArray) {
                [user addSubscriptionsObject:[RKSubreddit objectWithDictionary:[subredditObject objectForKey:@"data"]]];
            }
            
            user.subscriptionsAfter = [dataObject objectForKey:@"after"];
            
			[context save:nil];
		}];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
}

- (void)adjustSubscriptionToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user withAction:(NSString *)action success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                action, @"action",
                                user.modhash, @"uh",
                                [NSString stringWithFormat:@"t5_%@", subreddit.remoteID], @"sr",
                                nil];
    
    [self postAuthenticatedPath:@"api/subscribe" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Reload subscriptions
        
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
}

- (void)subscribeToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self adjustSubscriptionToSubreddit:subreddit withUser:user withAction:@"sub" success:success failure:failure];
}

- (void)unsubscribeToSubreddit:(RKSubreddit *)subreddit withUser:(RKUser *)user success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self adjustSubscriptionToSubreddit:subreddit withUser:user withAction:@"unsub" success:success failure:failure];
}

#pragma mark - Voting

- (void)voteWithUser:(RKUser *)user onLink:(RKLink *)link withDirection:(NSString *)direction success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"t3_%@", link.remoteID], @"id",
                                user.modhash, @"uh",
                                direction, @"dir",
                                nil];
    
    [self postAuthenticatedPath:@"api/vote" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // If there are any keys, it failed
        if (![[responseObject allKeys] count]) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:kRKErrorDomain code:kRKErrorUnknown userInfo:nil];
                failure((AFJSONRequestOperation *)operation, error);
            }
            return;
        }
        
        if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
}

- (void)upVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self voteWithUser:user onLink:link withDirection:@"1" success:success failure:failure];
}

- (void)downVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self voteWithUser:user onLink:link withDirection:@"-1" success:success failure:failure];
}

- (void)removeVoteWithUser:(RKUser *)user onLink:(RKLink *)link success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self voteWithUser:user onLink:link withDirection:@"0" success:success failure:failure];
}

#pragma mark - Subreddits

- (void)getSubredditWithTitle:(NSString *)title success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    NSLog(@"#RK#getSubredditWithTitle:%@", [NSString stringWithFormat:@"r/%@/about.json", title]);
    
    [self getPath:[NSString stringWithFormat:@"r/%@/about.json", title] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [RKSubreddit mainContext];
		[context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject objectForKey:@"data"];
            [RKSubreddit objectWithDictionary:dataObject];
            
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)getSubredditWithURL:(NSString *)url success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    NSLog(@"#RK#getSubredditWithURL:%@", [NSString stringWithFormat:@"%@about.json", url]);
    
    [self getPath:[NSString stringWithFormat:@"%@about.json", url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [RKSubreddit mainContext];
		[context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject objectForKey:@"data"];
            [RKSubreddit objectWithDictionary:dataObject];
            
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)getLinksForSubreddit:(RKSubreddit *)subreddit success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    [self getPath:[NSString stringWithFormat:@"%@.json?limit=%i", [subreddit.url substringWithRange:NSMakeRange(0, subreddit.url.length - 1)], kRKLinkLimit] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [RKLink mainContext];
		[context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject objectForKey:@"data"];
        
            subreddit.after = [dataObject objectForKey:@"after"];
            
            NSDictionary *childrenArray = [dataObject objectForKey:@"children"];
            for (NSDictionary *linkObject in childrenArray) {
                RKLink *link = [RKLink objectWithDictionary:[linkObject objectForKey:@"data"]];
                link.subreddit = subreddit;
            }
            
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)getMoreLinksForSubreddit:(RKSubreddit *)subreddit success:(RDRKHTTPClientSuccess)success failure:(RDRKHTTPClientFailure)failure
{
    if (!subreddit.after) {
        [self getLinksForSubreddit:subreddit success:success failure:failure];
        return;
    }
    
    [self getPath:[NSString stringWithFormat:@"%@.json?limit=%i&after=%@", [subreddit.url substringWithRange:NSMakeRange(0, subreddit.url.length - 1)], kRKLinkLimit, subreddit.after] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [RKLink mainContext];
		[context performBlockAndWait:^{
            NSDictionary *dataObject = [responseObject objectForKey:@"data"];
            
            subreddit.after = [dataObject objectForKey:@"after"];
            
            NSDictionary *childrenArray = [dataObject objectForKey:@"children"];
            for (NSDictionary *linkObject in childrenArray) {
                RKLink *link = [RKLink objectWithDictionary:[linkObject objectForKey:@"data"]];
                link.subreddit = subreddit;
            }
            
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

@end
