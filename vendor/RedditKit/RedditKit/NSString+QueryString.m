//
//  NSString+QueryString.m
//  RedditKit
//
//  Created by Robert Dougan on 8/9/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "NSString+QueryString.h"

@implementation NSString (QueryString)

- (NSString *)stringByEscapingForURLQuery
{
    NSString *result = self;
    
    CFStringRef originalAsCFString = (__bridge CFStringRef) self;
    CFStringRef leaveAlone = CFSTR(" ");
    CFStringRef toEscape = CFSTR("\n\r?[]()$,!'*;:@&=#%+/");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalAsCFString, leaveAlone, toEscape, kCFStringEncodingUTF8);
    
    if (escapedStr) {
        NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
        CFRelease(escapedStr);
        
        [mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
        result = mutable;
    }
    return result;
}

- (NSString *)stringByUnescapingFromURLQuery
{
    return [[self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

@end
