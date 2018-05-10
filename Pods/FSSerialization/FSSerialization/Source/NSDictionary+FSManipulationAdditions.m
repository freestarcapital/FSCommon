//
//  NSDictionary+MTLManipulationAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSDictionary+FSManipulationAdditions.h"

@implementation NSDictionary (FSManipulationAdditions)

- (NSDictionary *)fs_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
	NSMutableDictionary *result = [self mutableCopy];
	[result addEntriesFromDictionary:dictionary];
	return result;
}

- (NSDictionary *)fs_dictionaryByRemovingValuesForKeys:(NSArray *)keys {
	NSMutableDictionary *result = [self mutableCopy];
	[result removeObjectsForKeys:keys];
	return result;
}

@end
