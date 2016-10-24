//
//  LuxeService_NSURLConnectionRequest.h
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import <Foundation/Foundation.h>
#import "LuxeService.h"

@protocol LuxeService_NSURLConnectionRequestDelegate;

/**
 *  A class that wraps NSURLConnection for easier use and state-tracking
 */
@interface LuxeService_NSURLConnectionRequest : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate>


/**
 * Initialize a new instance
 * @param request A NSURLRequest for the underlying connection to execute
 * @param statusCode The expected HTTP status code signaling successful execution
 * @param success The callback block to execute upon successful completion
 * @param failure The failure block to execute if the connection fails for any reason
 */
-(instancetype)initWithRequest:(NSURLRequest *)request
            expectedStatusCode:(NSInteger)statusCode
                       success:(LuxeServiceSuccess)success
                       failure:(LuxeServiceFailure)failure
                      delegate:(id<LuxeService_NSURLConnectionRequestDelegate>)delegate;
/**
 * Cancel the underlying connection
 */
- (void)cancel;

/**
 * Restart the request
 */
- (void)restart;

/**
 * The unique identifier for the request, used to track instances separately
 */
- (NSString *)uniqueIdentifier;

@end

@protocol LuxeService_NSURLConnectionRequestDelegate < NSObject >

- (void) requestDidComplete:(LuxeService_NSURLConnectionRequest *)request;
- (void) requestRequiredAuthentication:(LuxeService_NSURLConnectionRequest *)request;

@end