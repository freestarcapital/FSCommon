//
//  NSDictionary+MTLMappingAdditions.h
//  Mantle
//
//  Created by Robert Böhnke on 10/31/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FSMappingAdditions)

/// Creates an identity mapping for serialization.
///
/// class - A subclass of MTLModel.
///
/// Returns a dictionary that maps all properties of the given class to
/// themselves.
+ (NSDictionary *)fs_identityPropertyMapWithModel:(Class)modelClass;

@end
