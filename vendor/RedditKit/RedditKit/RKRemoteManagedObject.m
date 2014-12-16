//
//  RDRKRemoteManagedObject.m
//  RedditKit
//
//  Created by Robert Dougan on 8/5/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RKRemoteManagedObject.h"

@implementation RKRemoteManagedObject

@dynamic remoteID;
@dynamic createdAt;

#pragma mark -

+ (id)objectWithRemoteID:(NSString *)remoteID {
	return [self objectWithRemoteID:remoteID context:nil];
}

+ (id)objectWithRemoteID:(NSString *)remoteID context:(NSManagedObjectContext *)context {
	// Look up the object
	RKRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];
	
	// If the object doesn't exist, create it
	if (!object) {
		object = [[self alloc] initWithContext:context];
		object.remoteID = remoteID;
	}
	
	// Return the fetched or new object
	return object;
}

+ (id)existingObjectWithRemoteID:(NSString *)remoteID {
	return [self existingObjectWithRemoteID:remoteID context:nil];
}

+ (id)existingObjectWithRemoteID:(NSString *)remoteID context:(NSManagedObjectContext *)context {
	// Default to the main context
	if (!context) {
		context = [self mainContext];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", remoteID];
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return nil;
	}
	
	// Return the object
	return [results objectAtIndex:0];
}

+ (id)existingObjectWithKey:(NSString *)key value:(NSString *)value
{
	NSManagedObjectContext *context = [self mainContext];
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return nil;
	}
	
	// Return the object
	return [results objectAtIndex:0];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary {
	return [self objectWithDictionary:dictionary context:nil];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	// If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSString *remoteID = [dictionary objectForKey:@"id"];
	
	// If there isn't a remoteID, we won't find the object. Return nil.
	if (!remoteID) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [self mainContext];
	}
	
	// Find or create the object
	RKRemoteManagedObject *object = [[self class] objectWithRemoteID:remoteID context:context];
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	
	// Return the new or updated object
	return object;
}

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary {
    return [self existingObjectWithDictionary:dictionary context:nil];
}

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	// If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSString *remoteID = [dictionary objectForKey:@"id"];
	
	// If there isn't a remoteID, we won't find the object. Return nil.
	if (!remoteID) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [self mainContext];
	}
	
	// Lookup the object
	RKRemoteManagedObject *object = [[self class] existingObjectWithRemoteID:remoteID context:context];
	if (!object) {
		return nil;
	}
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	
	// Return the new or updated object
	return object;
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	if (!self.isRemote) {
		self.remoteID = [dictionary objectForKey:@"id"];
	}
	
	self.createdAt = [[self class] parseDate:[dictionary objectForKey:@"created"]];
}

- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}

- (BOOL)isRemote {
	return (self.remoteID) ? YES : NO;
}

+ (NSDate *)parseDate:(id)dateStringOrDateNumber {
	// Return nil if nil is given
	if (!dateStringOrDateNumber || dateStringOrDateNumber == [NSNull null]) {
		return nil;
	}
	
	// Parse number
	if ([dateStringOrDateNumber isKindOfClass:[NSNumber class]]) {
		return [NSDate dateWithTimeIntervalSince1970:[dateStringOrDateNumber doubleValue]];
	}
	
	// Parse string
	else if ([dateStringOrDateNumber isKindOfClass:[NSString class]]) {
		// ISO8601 Parser borrowed from SSToolkit. http://sstoolk.it
		NSString *iso8601 = dateStringOrDateNumber;
		if (!iso8601) {
			return nil;
		}
		
		const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
		char newStr[25];
		
		struct tm tm;
		size_t len = strlen(str);
		if (len == 0) {
			return nil;
		}
		
		// UTC
		if (len == 20 && str[len - 1] == 'Z') {
			strncpy(newStr, str, len - 1);
			strncpy(newStr + len - 1, "+0000", 5);
		}
		
		// Timezone
		else if (len == 24 && str[22] == ':') {
			strncpy(newStr, str, 22);
			strncpy(newStr + 22, str + 23, 2);
		}
		
		// Poorly formatted timezone
		else {
			strncpy(newStr, str, len > 24 ? 24 : len);
		}
		
		// Add null terminator
		newStr[sizeof(newStr) - 1] = 0;
		
		if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
			return nil;
		}
		
		time_t t;
		t = mktime(&tm);
		
		return [NSDate dateWithTimeIntervalSince1970:t];
	}
	
	NSAssert1(NO, @"[RDRKRemoteManagedObject] Failed to parse date: %@", dateStringOrDateNumber);
	return nil;
}

+ (NSArray *)defaultSortDescriptors {
	return [NSArray arrayWithObjects:
			[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
			nil];
}

@end
