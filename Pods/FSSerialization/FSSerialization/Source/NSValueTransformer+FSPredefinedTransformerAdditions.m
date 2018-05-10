//
//  NSValueTransformer+MTLPredefinedTransformerAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-27.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSValueTransformer+FSPredefinedTransformerAdditions.h"
#import "FSJSONAdapter.h"
#import "FSModel.h"
#import "FSValueTransformer.h"

NSString * const FSURLValueTransformerName = @"FSURLValueTransformerName";
NSString * const FSUUIDValueTransformerName = @"FSUUIDValueTransformerName";
NSString * const FSBooleanValueTransformerName = @"FSBooleanValueTransformerName";

@implementation NSValueTransformer (FSPredefinedTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
	@autoreleasepool {
		FSValueTransformer *URLValueTransformer = [FSValueTransformer
			transformerUsingForwardBlock:^ id (NSString *str, BOOL *success, NSError **error) {
				if (str == nil) return nil;

				if (![str isKindOfClass:NSString.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to URL", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSString, got: %@.", @""), str],
							FSTransformerErrorHandlingInputValueErrorKey : str
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				NSURL *result = [NSURL URLWithString:str];

				if (result == nil) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to URL", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Input URL string %@ was malformed", @""), str],
							FSTransformerErrorHandlingInputValueErrorKey : str
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				return result;
			}
			reverseBlock:^ id (NSURL *URL, BOOL *success, NSError **error) {
				if (URL == nil) return nil;

				if (![URL isKindOfClass:NSURL.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert URL to string", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSURL, got: %@.", @""), URL],
							FSTransformerErrorHandlingInputValueErrorKey : URL
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				return URL.absoluteString;
			}];

		[NSValueTransformer setValueTransformer:URLValueTransformer forName:FSURLValueTransformerName];

		FSValueTransformer *UUIDValueTransformer = [FSValueTransformer
				transformerUsingForwardBlock:^id(NSString *string, BOOL *success, NSError **error) {
					if (string == nil) return nil;
					
					if (![string isKindOfClass:NSString.class]) {
						if (error) {
							NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to UUID", @""),
								NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSString, got: %@.", @""), string],
								FSTransformerErrorHandlingInputValueErrorKey : string
							};
							*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
						}
						*success = NO;
						return nil;
					}
					
					NSUUID *result = [[NSUUID alloc] initWithUUIDString:string];
					
					if (result == nil) {
						if (error) {
							NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to UUID", @""),
								NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Input UUID string %@ was malformed", @""), string],
													   FSTransformerErrorHandlingInputValueErrorKey : string
							};
							*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
						}
						*success = NO;
						return nil;
					}
					
					return result;
				}
				reverseBlock:^id(NSUUID *uuid, BOOL *success, NSError **error) {
					if (uuid == nil) return nil;
					
					if (![uuid isKindOfClass:NSUUID.class]) {
						if (error != NULL) {
							NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert UUID to string", @""),
													   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSUUID, got: %@.", @""), uuid],
													   FSTransformerErrorHandlingInputValueErrorKey : uuid};
							*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
						}
						*success = NO;
						return nil;
					}
					
					return uuid.UUIDString;
				}];
		
		[NSValueTransformer setValueTransformer:UUIDValueTransformer forName:FSUUIDValueTransformerName];
		
		FSValueTransformer *booleanValueTransformer = [FSValueTransformer
			transformerUsingReversibleBlock:^ id (NSNumber *boolean, BOOL *success, NSError **error) {
				if (boolean == nil) return nil;

				if (![boolean isKindOfClass:NSNumber.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert number to boolean-backed number or vice-versa", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSNumber, got: %@.", @""), boolean],
							FSTransformerErrorHandlingInputValueErrorKey : boolean
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				return (NSNumber *)(boolean.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
			}];

		[NSValueTransformer setValueTransformer:booleanValueTransformer forName:FSBooleanValueTransformerName];
	}
}

#pragma mark Customizable Transformers

+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_arrayMappingTransformerWithTransformer:(NSValueTransformer *)transformer {
	NSParameterAssert(transformer != nil);
	
	id (^forwardBlock)(NSArray *values, BOOL *success, NSError **error) = ^ id (NSArray *values, BOOL *success, NSError **error) {
		if (values == nil) return nil;
		
		if (![values isKindOfClass:NSArray.class]) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Could not transform non-array type", @""),
					NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), values],
					FSTransformerErrorHandlingInputValueErrorKey: values
				};
				
				*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
			}
			*success = NO;
			return nil;
		}
		
		NSMutableArray *transformedValues = [NSMutableArray arrayWithCapacity:values.count];
		NSInteger index = -1;
		for (id value in values) {
			index++;
			if (value == NSNull.null) {
				[transformedValues addObject:NSNull.null];
				continue;
			}
			
			id transformedValue = nil;
			if ([transformer conformsToProtocol:@protocol(FSTransformerErrorHandling)]) {
				NSError *underlyingError = nil;
				transformedValue = [(id<FSTransformerErrorHandling>)transformer transformedValue:value success:success error:&underlyingError];
				
				if (*success == NO) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not transform array", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Could not transform value at index %d", @""), index],
							NSUnderlyingErrorKey: underlyingError,
							FSTransformerErrorHandlingInputValueErrorKey: values
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					return nil;
				}
			} else {
				transformedValue = [transformer transformedValue:value];
			}
			
			if (transformedValue == nil) continue;
			
			[transformedValues addObject:transformedValue];
		}
		
		return transformedValues;
	};
	
	id (^reverseBlock)(NSArray *values, BOOL *success, NSError **error) = nil;
	if (transformer.class.allowsReverseTransformation) {
		reverseBlock = ^ id (NSArray *values, BOOL *success, NSError **error) {
			if (values == nil) return nil;
			
			if (![values isKindOfClass:NSArray.class]) {
				if (error != NULL) {
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"Could not transform non-array type", @""),
						NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), values],
						FSTransformerErrorHandlingInputValueErrorKey: values
					};

					*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
				}
				*success = NO;
				return nil;
			}
			
			NSMutableArray *transformedValues = [NSMutableArray arrayWithCapacity:values.count];
			NSInteger index = -1;
			for (id value in values) {
				index++;
				if (value == NSNull.null) {
					[transformedValues addObject:NSNull.null];

					continue;
				}
				
				id transformedValue = nil;
				if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
					NSError *underlyingError = nil;
					transformedValue = [(id<FSTransformerErrorHandling>)transformer reverseTransformedValue:value success:success error:&underlyingError];
					
					if (*success == NO) {
						if (error != NULL) {
							NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Could not transform array", @""),
								NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Could not transform value at index %d", @""), index],
								NSUnderlyingErrorKey: underlyingError,
								FSTransformerErrorHandlingInputValueErrorKey: values
							};
							
							*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
						}
						return nil;
					}
				} else {
					transformedValue = [transformer reverseTransformedValue:value];
				}
				
				if (transformedValue == nil) continue;
				
				[transformedValues addObject:transformedValue];
			}
			
			return transformedValues;
		};
	}
	if (reverseBlock != nil) {
		return [FSValueTransformer transformerUsingForwardBlock:forwardBlock reverseBlock:reverseBlock];
	} else {
		return [FSValueTransformer transformerUsingForwardBlock:forwardBlock];
	}
}

+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_validatingTransformerForClass:(Class)modelClass {
	NSParameterAssert(modelClass != nil);

	return [FSValueTransformer transformerUsingForwardBlock:^ id (id value, BOOL *success, NSError **error) {
		if (value != nil && ![value isKindOfClass:modelClass]) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Value did not match expected type", @""),
					NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected %1$@ to be of class %2$@ but got %3$@", @""), value, modelClass, [value class]],
					FSTransformerErrorHandlingInputValueErrorKey : value
				};

				*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
			}
			*success = NO;
			return nil;
		}

		return value;
	}];
}

+ (NSValueTransformer *)fs_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue {
	NSParameterAssert(dictionary != nil);
	NSParameterAssert(dictionary.count == [[NSSet setWithArray:dictionary.allValues] count]);

	return [FSValueTransformer
			transformerUsingForwardBlock:^ id (id <NSCopying> key, BOOL *success, NSError **error) {
				return dictionary[key ?: NSNull.null] ?: defaultValue;
			}
			reverseBlock:^ id (id value, BOOL *success, NSError **error) {
				__block id result = nil;
				[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id anObject, BOOL *stop) {
					if ([value isEqual:anObject]) {
						result = key;
						*stop = YES;
					}
				}];

				return result ?: reverseDefaultValue;
			}];
}

+ (NSValueTransformer *)fs_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary {
	return [self fs_valueMappingTransformerWithDictionary:dictionary defaultValue:nil reverseDefaultValue:nil];
}

+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_dateTransformerWithDateFormat:(NSString *)dateFormat calendar:(NSCalendar *)calendar locale:(NSLocale *)locale timeZone:(NSTimeZone *)timeZone defaultDate:(NSDate *)defaultDate {
	NSParameterAssert(dateFormat.length);

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = dateFormat;
	dateFormatter.calendar = calendar;
	dateFormatter.locale = locale;
	dateFormatter.timeZone = timeZone;
	dateFormatter.defaultDate = defaultDate;

	return [NSValueTransformer fs_transformerWithFormatter:dateFormatter forObjectClass:NSDate.class];
}


+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_dateTransformerWithDateFormat:(NSString *)dateFormat locale:(NSLocale *)locale {
	return [self fs_dateTransformerWithDateFormat:dateFormat calendar:nil locale:locale timeZone:nil defaultDate:nil];
}

+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_numberTransformerWithNumberStyle:(NSNumberFormatterStyle)numberStyle locale:(NSLocale *)locale {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = numberStyle;
	numberFormatter.locale = locale;

	return [self fs_transformerWithFormatter:numberFormatter forObjectClass:NSNumber.class];
}

+ (NSValueTransformer<FSTransformerErrorHandling> *)fs_transformerWithFormatter:(NSFormatter *)formatter forObjectClass:(Class)objectClass {
	NSParameterAssert(formatter != nil);
	NSParameterAssert(objectClass != nil);
	return [FSValueTransformer
			transformerUsingForwardBlock:^ id (NSString *str, BOOL *success, NSError *__autoreleasing *error) {
				if (str == nil) return nil;

				if (![str isKindOfClass:NSString.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
						    NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Could not convert string to %@", @""), objectClass],
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSString as input, got: %@.", @""), str],
							FSTransformerErrorHandlingInputValueErrorKey : str
						};
						
						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				id object = nil;
				NSString *errorDescription = nil;
				*success = [formatter getObjectValue:&object forString:str errorDescription:&errorDescription];

				if (errorDescription != nil) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Could not convert string to %@", @""), objectClass],
							NSLocalizedFailureReasonErrorKey: errorDescription,
							FSTransformerErrorHandlingInputValueErrorKey : str
						};
						
						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				if (![object isKindOfClass:objectClass]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Could not convert string to %@", @""), objectClass],
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an %@ as output from the formatter, got: %@.", @""), objectClass, object],
						};

						*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				return object;
			} reverseBlock:^id(id object, BOOL *success, NSError *__autoreleasing *error) {
				if (object == nil) return nil;

				if (![object isKindOfClass:objectClass]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
						   NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Could not convert %@ to string", @""), objectClass],
						   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an %@ as input, got: %@.", @""), objectClass, object],
						   FSTransformerErrorHandlingInputValueErrorKey : object
						};

						*error = [NSError errorWithDomain:FSTransformerErrorHandlingErrorDomain code:FSTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				NSString *string = [formatter stringForObjectValue:object];
				*success = (string != nil);
				return string;
			}];
}

@end
