//
//  NSError+MTLModelException.m
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "FSModel.h"

#import "NSError+FSModelException.h"

// The domain for errors originating from FSModel.
static NSString * const FSModelErrorDomain = @"FSModelErrorDomain";

// An exception was thrown and caught.
static const NSInteger FSModelErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
static NSString * const FSModelThrownExceptionErrorKey = @"FSModelThrownException";

@implementation NSError (FSModelException)

+ (instancetype)fs_modelErrorWithException:(NSException *)exception {
	NSParameterAssert(exception != nil);

	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: exception.description,
		NSLocalizedFailureReasonErrorKey: exception.reason,
		FSModelThrownExceptionErrorKey: exception
	};

	return [NSError errorWithDomain:FSModelErrorDomain code:FSModelErrorExceptionThrown userInfo:userInfo];
}

@end
