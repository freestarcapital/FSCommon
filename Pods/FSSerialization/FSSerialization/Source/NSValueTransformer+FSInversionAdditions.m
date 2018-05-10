//
//  NSValueTransformer+MTLInversionAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2013-05-18.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSValueTransformer+FSInversionAdditions.h"
#import "FSTransformerErrorHandling.h"
#import "FSValueTransformer.h"

@implementation NSValueTransformer (FSInversionAdditions)

- (NSValueTransformer *)fs_invertedTransformer {
	NSParameterAssert(self.class.allowsReverseTransformation);

	if ([self conformsToProtocol:@protocol(FSTransformerErrorHandling)]) {
		NSParameterAssert([self respondsToSelector:@selector(reverseTransformedValue:success:error:)]);

		id<FSTransformerErrorHandling> errorHandlingSelf = (id)self;

		return [FSValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError **error) {
			return [errorHandlingSelf reverseTransformedValue:value success:success error:error];
		} reverseBlock:^(id value, BOOL *success, NSError **error) {
			return [errorHandlingSelf transformedValue:value success:success error:error];
		}];
	} else {
		return [FSValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError **error) {
			return [self reverseTransformedValue:value];
		} reverseBlock:^(id value, BOOL *success, NSError **error) {
			return [self transformedValue:value];
		}];
	}
}

@end
