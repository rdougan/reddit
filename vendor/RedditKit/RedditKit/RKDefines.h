//
//  RDRKDefines.h
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kRKURLScheme;
extern NSString *const kRKURLSecureScheme;
extern NSString *const kRKURLDomain;

extern NSString *const kRKErrorDomain;
enum {
    kRKErrorUnknown,
    kRKErrorWrongPassword,
    kRKErrorRateLimit
};
NSInteger const kRDRKError;

extern NSString *const kRKKeychainService;

extern int const kRKLinkLimit;

#pragma mark Notifications
extern NSString *const kRKCurrentUserChangedNotificationName;