//
//  FSValueTransformer.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "FSValueTransformer.h"

//
// Any FSValueTransformer supporting reverse transformation. Necessary because
// +allowsReverseTransformation is a class method.
//
@interface FSReversibleValueTransformer : FSValueTransformer
@end

@interface FSValueTransformer ()

@property (nonatomic, copy, readonly) FSValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) FSValueTransformerBlock reverseBlock;

@end

@implementation FSValueTransformer

#pragma mark Lifecycle

+ (instancetype)transformerUsingForwardBlock:(FSValueTransformerBlock)forwardBlock {
	return [[self alloc] initWithForwardBlock:forwardBlock reverseBlock:nil];
}

+ (instancetype)transformerUsingReversibleBlock:(FSValueTransformerBlock)reversibleBlock {
	return [self transformerUsingForwardBlock:reversibleBlock reverseBlock:reversibleBlock];
}

+ (instancetype)transformerUsingForwardBlock:(FSValueTransformerBlock)forwardBlock reverseBlock:(FSValueTransformerBlock)reverseBlock {
	return [[FSReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (id)initWithForwardBlock:(FSValueTransformerBlock)forwardBlock reverseBlock:(FSValueTransformerBlock)reverseBlock {
	NSParameterAssert(forwardBlock != nil);

	self = [super init];
	if (self == nil) return nil;

	_forwardBlock = [forwardBlock copy];
	_reverseBlock = [reverseBlock copy];

	return self;
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return NSObject.class;
}

- (id)transformedValue:(id)value {
	NSError *error = nil;
	BOOL success = YES;

	return self.forwardBlock(value, &success, &error);
}

- (id)transformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
	NSError *error = nil;
	BOOL success = YES;

	id transformedValue = self.forwardBlock(value, &success, &error);

	if (outerSuccess != NULL) *outerSuccess = success;
	if (outerError != NULL) *outerError = error;

	return transformedValue;
}

@end

@implementation FSReversibleValueTransformer

#pragma mark Lifecycle

- (id)initWithForwardBlock:(FSValueTransformerBlock)forwardBlock reverseBlock:(FSValueTransformerBlock)reverseBlock {
	NSParameterAssert(reverseBlock != nil);
	return [super initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)reverseTransformedValue:(id)value {
	NSError *error = nil;
	BOOL success = YES;

	return self.reverseBlock(value, &success, &error);
}

- (id)reverseTransformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
	NSError *error = nil;
	BOOL success = YES;

	id transformedValue = self.reverseBlock(value, &success, &error);

	if (outerSuccess != NULL) *outerSuccess = success;
	if (outerError != NULL) *outerError = error;

	return transformedValue;
}

@end
