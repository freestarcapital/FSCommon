//
//  FSModel.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSError+FSModelException.h"
#import "FSModel.h"
#import "EXTRuntimeExtensions.h"
#import "EXTScope.h"
#import "FSReflection.h"
#import <objc/runtime.h>

// Used to cache the reflection performed in +propertyKeys.
static void *FSModelCachedPropertyKeysKey = &FSModelCachedPropertyKeysKey;

// Associated in +generateAndCachePropertyKeys with a set of all transitory
// property keys.
static void *FSModelCachedTransitoryPropertyKeysKey = &FSModelCachedTransitoryPropertyKeysKey;

// Associated in +generateAndCachePropertyKeys with a set of all permanent
// property keys.
static void *FSModelCachedPermanentPropertyKeysKey = &FSModelCachedPermanentPropertyKeysKey;

// Validates a value for an object and sets it if necessary.
//
// obj         - The object for which the value is being validated. This value
//               must not be nil.
// key         - The name of one of `obj`s properties. This value must not be
//               nil.
// value       - The new value for the property identified by `key`.
// forceUpdate - If set to `YES`, the value is being updated even if validating
//               it did not change it.
// error       - If not NULL, this may be set to any error that occurs during
//               validation
//
// Returns YES if `value` could be validated and set, or NO if an error
// occurred.
static BOOL FSValidateAndSetValue(id obj, NSString *key, id value, BOOL forceUpdate, NSError **error) {
	// Mark this as being autoreleased, because validateValue may return
	// a new object to be stored in this variable (and we don't want ARC to
	// double-free or leak the old or new values).
	__autoreleasing id validatedValue = value;

	@try {
		if (![obj validateValue:&validatedValue forKey:key error:error]) return NO;

		if (forceUpdate || value != validatedValue) {
			[obj setValue:validatedValue forKey:key];
		}

		return YES;
	} @catch (NSException *ex) {
		NSLog(@"*** Caught exception setting key \"%@\" : %@", key, ex);

		// Fail fast in Debug builds.
		#if DEBUG
		@throw ex;
		#else
		if (error != NULL) {
			*error = [NSError fs_modelErrorWithException:ex];
		}

		return NO;
		#endif
	}
}

@interface FSModel ()

// Inspects all properties of returned by +propertyKeys using
// +storageBehaviorForPropertyWithKey and caches the results.
+ (void)generateAndCacheStorageBehaviors;

// Returns a set of all property keys for which
// +storageBehaviorForPropertyWithKey returned FSPropertyStorageTransitory.
+ (NSSet *)transitoryPropertyKeys;

// Returns a set of all property keys for which
// +storageBehaviorForPropertyWithKey returned FSPropertyStoragePermanent.
+ (NSSet *)permanentPropertyKeys;

// Enumerates all properties of the receiver's class hierarchy, starting at the
// receiver, and continuing up until (but not including) FSModel.
//
// The given block will be invoked multiple times for any properties declared on
// multiple classes in the hierarchy.
+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block;

@end

@implementation FSModel

#pragma mark Lifecycle

+ (void)generateAndCacheStorageBehaviors {
	NSMutableSet *transitoryKeys = [NSMutableSet set];
	NSMutableSet *permanentKeys = [NSMutableSet set];

	for (NSString *propertyKey in self.propertyKeys) {
		switch ([self storageBehaviorForPropertyWithKey:propertyKey]) {
			case FSPropertyStorageNone:
				break;

			case FSPropertyStorageTransitory:
				[transitoryKeys addObject:propertyKey];
				break;

			case FSPropertyStoragePermanent:
				[permanentKeys addObject:propertyKey];
				break;
		}
	}

	// It doesn't really matter if we replace another thread's work, since we do
	// it atomically and the result should be the same.
	objc_setAssociatedObject(self, FSModelCachedTransitoryPropertyKeysKey, transitoryKeys, OBJC_ASSOCIATION_COPY);
	objc_setAssociatedObject(self, FSModelCachedPermanentPropertyKeysKey, permanentKeys, OBJC_ASSOCIATION_COPY);
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
	return [[self alloc] initWithDictionary:dictionary error:error];
}

- (instancetype)init {
	// Nothing special by default, but we have a declaration in the header.
	return [super init];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
	self = [self init];
	if (self == nil) return nil;

	for (NSString *key in dictionary) {
		// Mark this as being autoreleased, because validateValue may return
		// a new object to be stored in this variable (and we don't want ARC to
		// double-free or leak the old or new values).
		__autoreleasing id value = [dictionary objectForKey:key];

		if ([value isEqual:NSNull.null]) value = nil;

		BOOL success = FSValidateAndSetValue(self, key, value, YES, error);
		if (!success) return nil;
	}

	return self;
}

#pragma mark Reflection

+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
	Class cls = self;
	BOOL stop = NO;

	while (!stop && ![cls isEqual:FSModel.class]) {
		unsigned count = 0;
		objc_property_t *properties = class_copyPropertyList(cls, &count);

		cls = cls.superclass;
		if (properties == NULL) continue;

		@onExit {
			free(properties);
		};

		for (unsigned i = 0; i < count; i++) {
			block(properties[i], &stop);
			if (stop) break;
		}
	}
}

+ (NSSet *)propertyKeys {
	NSSet *cachedKeys = objc_getAssociatedObject(self, FSModelCachedPropertyKeysKey);
	if (cachedKeys != nil) return cachedKeys;

	NSMutableSet *keys = [NSMutableSet set];

	[self enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
		NSString *key = @(property_getName(property));

		if ([self storageBehaviorForPropertyWithKey:key] != FSPropertyStorageNone) {
			 [keys addObject:key];
		}
	}];

	// It doesn't really matter if we replace another thread's work, since we do
	// it atomically and the result should be the same.
	objc_setAssociatedObject(self, FSModelCachedPropertyKeysKey, keys, OBJC_ASSOCIATION_COPY);

	return keys;
}

+ (NSSet *)transitoryPropertyKeys {
	NSSet *transitoryPropertyKeys = objc_getAssociatedObject(self, FSModelCachedTransitoryPropertyKeysKey);

	if (transitoryPropertyKeys == nil) {
		[self generateAndCacheStorageBehaviors];
		transitoryPropertyKeys = objc_getAssociatedObject(self, FSModelCachedTransitoryPropertyKeysKey);
	}

	return transitoryPropertyKeys;
}

+ (NSSet *)permanentPropertyKeys {
	NSSet *permanentPropertyKeys = objc_getAssociatedObject(self, FSModelCachedPermanentPropertyKeysKey);

	if (permanentPropertyKeys == nil) {
		[self generateAndCacheStorageBehaviors];
		permanentPropertyKeys = objc_getAssociatedObject(self, FSModelCachedPermanentPropertyKeysKey);
	}

	return permanentPropertyKeys;
}

- (NSDictionary *)dictionaryValue {
	NSSet *keys = [self.class.transitoryPropertyKeys setByAddingObjectsFromSet:self.class.permanentPropertyKeys];

	return [self dictionaryWithValuesForKeys:keys.allObjects];
}

+ (FSPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey {
	objc_property_t property = class_getProperty(self.class, propertyKey.UTF8String);

	if (property == NULL) return FSPropertyStorageNone;

	fs_propertyAttributes *attributes = fs_copyPropertyAttributes(property);
	@onExit {
		free(attributes);
	};
	
	BOOL hasGetter = [self instancesRespondToSelector:attributes->getter];
	BOOL hasSetter = [self instancesRespondToSelector:attributes->setter];
	if (!attributes->dynamic && attributes->ivar == NULL && !hasGetter && !hasSetter) {
		return FSPropertyStorageNone;
	} else if (attributes->readonly && attributes->ivar == NULL) {
		if ([self isEqual:FSModel.class]) {
			return FSPropertyStorageNone;
		} else {
			// Check superclass in case the subclass redeclares a property that
			// falls through
			return [self.superclass storageBehaviorForPropertyWithKey:propertyKey];
		}
	} else {
		return FSPropertyStoragePermanent;
	}
}

#pragma mark Merging

- (void)mergeValueForKey:(NSString *)key fromModel:(NSObject<FSModel> *)model {
	NSParameterAssert(key != nil);

	SEL selector = FSSelectorWithCapitalizedKeyPattern("merge", key, "FromModel:");
	if (![self respondsToSelector:selector]) {
		if (model != nil) {
			[self setValue:[model valueForKey:key] forKey:key];
		}

		return;
	}

	IMP imp = [self methodForSelector:selector];
	void (*function)(id, SEL, id<FSModel>) = (__typeof__(function))imp;
	function(self, selector, model);
}

- (void)mergeValuesForKeysFromModel:(id<FSModel>)model {
	NSSet *propertyKeys = model.class.propertyKeys;

	for (NSString *key in self.class.propertyKeys) {
		if (![propertyKeys containsObject:key]) continue;

		[self mergeValueForKey:key fromModel:model];
	}
}

#pragma mark Validation

- (BOOL)validate:(NSError **)error {
	for (NSString *key in self.class.propertyKeys) {
		id value = [self valueForKey:key];

		BOOL success = FSValidateAndSetValue(self, key, value, NO, error);
		if (!success) return NO;
	}

	return YES;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	FSModel *copy = [[self.class allocWithZone:zone] init];
	[copy setValuesForKeysWithDictionary:self.dictionaryValue];
	return copy;
}

#pragma mark NSObject

- (NSString *)description {
	NSDictionary *permanentProperties = [self dictionaryWithValuesForKeys:self.class.permanentPropertyKeys.allObjects];

	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, permanentProperties];
}

- (NSUInteger)hash {
	NSUInteger value = 0;

	for (NSString *key in self.class.permanentPropertyKeys) {
		value ^= [[self valueForKey:key] hash];
	}

	return value;
}

- (BOOL)isEqual:(FSModel *)model {
	if (self == model) return YES;
	if (![model isMemberOfClass:self.class]) return NO;

	for (NSString *key in self.class.permanentPropertyKeys) {
		id selfValue = [self valueForKey:key];
		id modelValue = [model valueForKey:key];

		BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
		if (!valuesEqual) return NO;
	}

	return YES;
}

@end
