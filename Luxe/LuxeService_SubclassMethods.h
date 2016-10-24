//
//  LuxeService_SubclassMethods.h
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//

#import <Foundation/Foundation.h>

#import "LuxeService.h"

/**
 * A way for subclasses to "see" into the parent LuxeService class
 *  without exposing all the properties.
 */
@interface LuxeService (SubclassMethods)

@property (nonatomic, strong) NSURL *tempServerRoot;
@property (nonatomic, strong, readonly) NSMutableDictionary *requests;
@property (nonatomic, strong, readonly) NSMutableArray *requestsPendingAuthentication;

/**
 * Creates a NSMutableURLRequest for the given URL and HTTP method.  If the
 *  body is non-nil, it will be encoded using the -formEncodedParameters method.
 *  This method also sets several important HTTP headers.
 *  @param URL
 *  @param httpMethod
 *  @param bodyDict
 *  @param NSMutableURLRequest
 */
- (NSMutableURLRequest *)requestForURL:(NSURL *)URL
                              method:(NSString *)httpMethod
                              bodyDict:(NSDictionary *)bodyDict;

@end