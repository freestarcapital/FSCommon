//
//  FSURLResponseSerialization.h
//  FSNetworking
//
//  Created by Dean Chang on 4/16/18.
//  Copyright © 2018 Freestar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `FSURLResponseSerialization` protocol is adopted by an object that decodes data into a more useful object representation, according to details in the server response. Response serializers may additionally perform validation on the incoming response and data.
 
 For example, a JSON response serializer may check for an acceptable status code (`2XX` range) and content type (`application/json`), decoding a valid JSON response into an object.
 */
@protocol FSURLResponseSerialization <NSObject, NSSecureCoding, NSCopying>

/**
 The response object decoded from the data associated with a specified response.
 
 @param response The response to be processed.
 @param data The response data to be decoded.
 @param error The error that occurred while attempting to decode the response data.
 
 @return The object decoded from the specified response data.
 */
- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

#pragma mark -

/**
 `FSHTTPResponseSerializer` conforms to the `FSURLRequestSerialization` & `FSURLResponseSerialization` protocols, offering a concrete base implementation of query string / URL form-encoded parameter serialization and default request headers, as well as response status code and content type validation.
 
 Any request or response serializer dealing with HTTP is encouraged to subclass `FSHTTPResponseSerializer` in order to ensure consistent default behavior.
 */
@interface FSHTTPResponseSerializer : NSObject <FSURLResponseSerialization>

- (instancetype)init;

@property (nonatomic, assign) NSStringEncoding stringEncoding DEPRECATED_MSG_ATTRIBUTE("The string encoding is never used. FSHTTPResponseSerializerFS only validates status codes and content types but does not try to decode the received data in any way.");

/**
 Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

///-----------------------------------------
/// @name Configuring Response Serialization
///-----------------------------------------

/**
 The acceptable HTTP status codes for responses. When non-`nil`, responses with status codes not contained by the set will result in an error during validation.
 
 See http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 */
@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

/**
 The acceptable MIME types for responses. When non-`nil`, responses with a `Content-Type` with MIME types that do not intersect with the set will result in an error during validation.
 */
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

/**
 Validates the specified response and data.
 
 In its base implementation, this method checks for an acceptable status code and content type. Subclasses may wish to add other domain-specific checks.
 
 @param response The response to be validated.
 @param data The data associated with the response.
 @param error The error that occurred while attempting to validate the response.
 
 @return `YES` if the response is valid, otherwise `NO`.
 */
- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

@end

#pragma mark -


/**
 `FSJSONResponseSerializer` is a subclass of `FSHTTPResponseSerializer` that validates and decodes JSON responses.
 
 By default, `FSJSONResponseSerializer` accepts the following MIME types, which includes the official standard, `application/json`, as well as other commonly-used types:
 
 - `application/json`
 - `text/json`
 - `text/javascript`
 
 In RFC 7159 - Section 8.1, it states that JSON text is required to be encoded in UTF-8, UTF-16, or UTF-32, and the default encoding is UTF-8. NSJSONSerialization provides support for all the encodings listed in the specification, and recommends UTF-8 for efficiency. Using an unsupported encoding will result in serialization error. See the `NSJSONSerialization` documentation for more details.
 */
@interface FSJSONResponseSerializer : FSHTTPResponseSerializer

- (instancetype)init;

/**
 Options for reading the response JSON data and creating the Foundation objects. For possible values, see the `NSJSONSerialization` documentation section "NSJSONReadingOptions". `0` by default.
 */
@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

/**
 Whether to remove keys with `NSNull` values from response JSON. Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL removesKeysWithNullValues;

/**
 Creates and returns a JSON serializer with specified reading and writing options.
 
 @param readingOptions The specified JSON reading options.
 */
+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

#pragma mark -

/**
 `FSXMLParserResponseSerializer` is a subclass of `FSHTTPResponseSerializer` that validates and decodes XML responses as an `NSXMLParser` objects.
 
 By default, `FSXMLParserResponseSerializer` accepts the following MIME types, which includes the official standard, `application/xml`, as well as other commonly-used types:
 
 - `application/xml`
 - `text/xml`
 */
@interface FSXMLParserResponseSerializer : FSHTTPResponseSerializer

@end

#pragma mark -

/**
 `FSPropertyListResponseSerializer` is a subclass of `FSHTTPResponseSerializer` that validates and decodes XML responses as an `NSXMLDocument` objects.
 
 By default, `FSPropertyListResponseSerializer` accepts the following MIME types:
 
 - `application/x-plist`
 */
@interface FSPropertyListResponseSerializer : FSHTTPResponseSerializer

- (instancetype)init;

/**
 The property list format. Possible values are described in "NSPropertyListFormat".
 */
@property (nonatomic, assign) NSPropertyListFormat format;

/**
 The property list reading options. Possible values are described in "NSPropertyListMutabilityOptions."
 */
@property (nonatomic, assign) NSPropertyListReadOptions readOptions;

/**
 Creates and returns a property list serializer with a specified format, read options, and write options.
 
 @param format The property list format.
 @param readOptions The property list reading options.
 */
+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;

@end

#pragma mark -

/**
 `FSImageResponseSerializer` is a subclass of `FSHTTPResponseSerializer` that validates and decodes image responses.
 
 By default, `FSImageResponseSerializer` accepts the following MIME types, which correspond to the image formats supported by UIImage or NSImage:
 
 - `image/tiff`
 - `image/jpeg`
 - `image/gif`
 - `image/png`
 - `image/ico`
 - `image/x-icon`
 - `image/bmp`
 - `image/x-bmp`
 - `image/x-xbitmap`
 - `image/x-win-bitmap`
 */
@interface FSImageResponseSerializer : FSHTTPResponseSerializer

/**
 The scale factor used when interpreting the image data to construct `responseImage`. Specifying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the size property. This is set to the value of scale of the main screen by default, which automatically scales images for retina displays, for instance.
 */
@property (nonatomic, assign) CGFloat imageScale;

/**
 Whether to automatically inflate response image data for compressed formats (such as PNG or JPEG). Enabling this can significantly improve drawing performance on iOS when used with `setCompletionBlockWithSuccess:failure:`, as it allows a bitmap representation to be constructed in the background rather than on the main thread. `YES` by default.
 */
@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;

@end

#pragma mark -

/**
 `FSCompoundSerializer` is a subclass of `FSHTTPResponseSerializer` that delegates the response serialization to the first `FSHTTPResponseSerializer` object that returns an object for `responseObjectForResponse:data:error:`, falling back on the default behavior of `FSHTTPResponseSerializer`. This is useful for supporting multiple potential types and structures of server responses with a single serializer.
 */
@interface FSCompoundResponseSerializer : FSHTTPResponseSerializer

/**
 The component response serializers.
 */
@property (readonly, nonatomic, copy) NSArray <id<FSURLResponseSerialization>> *responseSerializers;

/**
 Creates and returns a compound serializer comprised of the specified response serializers.
 
 @warning Each response serializer specified must be a subclass of `FSHTTPResponseSerializer`, and response to `-validateResponse:data:error:`.
 */
+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray <id<FSURLResponseSerialization>> *)responseSerializers;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Error Domains
 
 The following error domain is predefined.
 
 - `NSString * const FSURLResponseSerializationErrorDomain`
 
 ### Constants
 
 `FSURLResponseSerializationErrorDomain`
 FSURLResponseSerializer errors. Error codes for `FSURLResponseSerializationErrorDomain` correspond to codes in `NSURLErrorDomain`.
 */
extern NSString * const FSURLResponseSerializationErrorDomain;

/**
 ## User info dictionary keys
 
 These keys may exist in the user info dictionary, in addition to those defined for NSError.
 
 - `NSString * const FSNetworkingOperationFailingURLResponseErrorKey`
 - `NSString * const FSNetworkingOperationFailingURLResponseDataErrorKey`
 
 ### Constants
 
 `FSNetworkingOperationFailingURLResponseErrorKey`
 The corresponding value is an `NSURLResponse` containing the response of the operation associated with an error. This key is only present in the `FSURLResponseSerializationErrorDomain`.
 
 `FSNetworkingOperationFailingURLResponseDataErrorKey`
 The corresponding value is an `NSData` containing the original data of the operation associated with an error. This key is only present in the `FSURLResponseSerializationErrorDomain`.
 */
extern NSString * const FSNetworkingOperationFailingURLResponseErrorKey;

extern NSString * const FSNetworkingOperationFailingURLResponseDataErrorKey;


NS_ASSUME_NONNULL_END
