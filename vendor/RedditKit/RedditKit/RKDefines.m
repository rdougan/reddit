//
//  RDRKDefines.m
//  RedditKit
//
//  Created by Robert Dougan on 8/3/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKDefines.h"

NSString *const kRKURLScheme = @"http://";
NSString *const kRKURLSecureScheme = @"https://";
NSString *const kRKURLDomain = @"www.reddit.com/";

NSString *const kRKErrorDomain = @"com.rdougan.reddit";

NSString *const kRKKeychainService = @"Reddit";

int const kRKLinkLimit = 100; // Max of 100

#pragma mark Notifications
NSString *const kRKCurrentUserChangedNotificationName = @"RKCurrentUserChangedNotification";