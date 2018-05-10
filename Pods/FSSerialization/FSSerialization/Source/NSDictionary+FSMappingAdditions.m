//
//  NSDictionary+MTLMappingAdditions.m
//  Mantle
//
//  Created by Robert Böhnke on 10/31/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "FSModel.h"

#import "NSDictionary+FSMappingAdditions.h"

@implementation NSDictionary (FSMappingAdditions)

+ (NSDictionary *)fs_identityPropertyMapWithModel:(Class)modelClass {
	NSCParameterAssert([modelClass conformsToProtocol:@protocol(FSModel)]);

	NSArray *propertyKeys = [modelClass propertyKeys].allObjects;

	return [NSDictionary dictionaryWithObjects:propertyKeys forKeys:propertyKeys];
}

@end
