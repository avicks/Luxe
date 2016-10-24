//
//  LuxeService_NSURLSessionRequest.h
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import <Foundation/Foundation.h>

#import "LuxeService.h"

@protocol LuxeService_NSURLSessionRequestDelegate;

/**
 * An instance of this class models a request encapsulated in a
 *  NSURLSessionDataTask.  It also tracks its unique identifier as
 *  well as the expected HTTP status codes, and the appropriate
 *  dispatch blocks for the success and failure cases.
 */
@interface LuxeService_NSURLSessionRequest : NSObject

@property (nonatomic, weak)id<LuxeService_NSURLSessionRequestDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, assign) NSInteger expectedStatus;
@property (nonatomic, copy) LuxeServiceSuccess successBlock;
@property (nonatomic, copy) LuxeServiceFailure failureBlock;

/**
 * Initialize a new instance which will immediately schedule the request.  Delegate
 *  methods will be invoked depending on the final response.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                   usingSession:(NSURLSession *)session
                 expectedStatus:(NSInteger)expectedStatus
                        success:(LuxeServiceSuccess)success
                        failure:(LuxeServiceFailure)failure
                       delegate:(id<LuxeService_NSURLSessionRequestDelegate>)delegate;

/**
 * Cancel this request
 */
- (void)cancel;

/**
 * Restart this request.  Delegate methods should be invoked depending on final response
 */
- (void)restart;

/**
 * The unique identifier of the request
 */
- (NSString *)requestIdentifier;

@end

@protocol LuxeService_NSURLSessionRequestDelegate <NSObject>

/**
 * Indicates that the request completed successfully with the response
 * returned the expected status code.
 */
- (void)sessionRequestDidComplete:(LuxeService_NSURLSessionRequest *)request;

/**
 * Indicates that the request failed for some reason, described in the given error
 */
- (void)sessionRequestFailed:(LuxeService_NSURLSessionRequest *)request error:(NSError *)error;

/**
 * Indicates that the request failed authentication (401 response) and requires
 * authentication before proceeding.
 */
- (void)sessionRequestRequiresAuthentication:(LuxeService_NSURLSessionRequest *)request;

@end