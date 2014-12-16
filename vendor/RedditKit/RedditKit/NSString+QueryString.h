//
//  NSString+QueryString.h
//  RedditKit
//
//  Created by Robert Dougan on 8/9/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QueryString)

- (NSString *)stringByEscapingForURLQuery;
- (NSString *)stringByUnescapingFromURLQuery;

@end
