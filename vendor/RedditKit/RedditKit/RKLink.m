//
//  RDRKLink.m
//  RedditKit
//
//  Created by Robert Dougan on 8/5/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKLink.h"

@interface RKLink ()
- (void)parseType;
@end

@implementation RKLink

@dynamic url;
@dynamic title;
@dynamic author;
@dynamic permalink;
@dynamic ups;
@dynamic downs;
@dynamic score;
@dynamic subreddit;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"Link";
}

#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
    
	self.url = [dictionary objectForKey:@"url"];
	self.title = [dictionary objectForKey:@"title"];
	self.author = [dictionary objectForKey:@"author"];
	self.permalink = [dictionary objectForKey:@"permalink"];
	self.ups = [dictionary objectForKey:@"ups"];
	self.downs = [dictionary objectForKey:@"downs"];
	self.score = [dictionary objectForKey:@"score"];
    
    [self parseType];
}

- (void)parseType
{
    RKLinkType type = RKLinkTypeURL;
    
    
    // direct files
    if ([self.url hasSuffix:@"png"] || [self.url hasSuffix:@"gif"] || [self.url hasSuffix:@"jpg"] || [self.url hasSuffix:@"jpeg"]) {
        self.type = RKLinkTypeImage;
        return;
    }
    
    // imgur without direct file
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"http://([i.]*)imgur.com/([a-zA-Z0-9]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.url options:0 range:NSMakeRange(0, [self.url length])];
    
    if (numberOfMatches > 0) {
        self.url = [NSString stringWithFormat:@"%@.jpg", self.url];
        self.type = RKLinkTypeImage;
        return;
    }
    
    // quickmeme
    
    
    self.type = type;
}

#pragma mark Setters/Getters

- (void)setType:(RKLinkType)type
{
    NSNumber *numberValue = [NSNumber numberWithLong:type];
    [self willChangeValueForKey:@"type"];
    [self setPrimitiveValue:numberValue forKey:@"type"];
    [self didChangeValueForKey:@"type"];
}

- (RKLinkType)type
{
    [self willAccessValueForKey:@"type"];
    NSNumber *numberValue = [self primitiveValueForKey:@"type"];
    [self didAccessValueForKey:@"type"];
    
    return (RKLinkType)[numberValue longValue];
}

@end
