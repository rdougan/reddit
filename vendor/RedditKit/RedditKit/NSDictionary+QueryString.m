//
//  NSDictionary+QueryString.m
//  RedditKit
//
//  Created by Robert Dougan on 8/9/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "NSDictionary+QueryString.h"
#import "NSString+QueryString.h"

@implementation NSDictionary (QueryString)

- (NSString *)queryString
{
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSString *key in self)
    {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                              [key stringByEscapingForURLQuery],
                              [[[self objectForKey:key] description] stringByEscapingForURLQuery]]];
    }
    
    return [arguments componentsJoinedByString:@"&"];
}

@end
