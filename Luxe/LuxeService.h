//
//  LuxeService.h
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import <Foundation/Foundation.h>

@class LuxeUser;


/*
 * Notification posted when an attempt to retrieve authenticated
 * resouces is met with a reply indicating incorrect or missing
 * credentials.
 */
extern NSString * const LuxeServiceAuthRequiredNotification;

// common callback block signatures for success/failure of remote calls
typedef void(^LuxeServiceSuccess)(NSData *data);
typedef void(^LuxeServiceFailure)(NSError *error);

/**
 * Base class defining a service that encapsulates access to backend REST server.
 *  All methods return immediately and callblock blocks are invoked asynchronously
 *  (on main thread) depending on success / failure.
 *
 * Each operation returns a unique identifier for that operation that can later
 *  be cancelled with a call to -cancelRequestWithIdentifier:
 */
@interface LuxeService : NSObject

#pragma mark - Singleton access

+ (LuxeService *)sharedInstance;

#pragma mark - User Data Retrieval
/**
 * Retrieve past trips for a given user
 * @param userID The user ID of the user
 * @param success The callback block for a successful trip history request
 * @param failure The callback block for a failed trip history request
 * @return NSString identifier for the operation, suitable for canceling with
 * @  -cancelRequestWithIdentifier:
 */
- (NSString *)getTripHistory:(NSString *)userID
                     success:(LuxeServiceSuccess)success
                     failure:(LuxeServiceFailure)failure;


#pragma mark - User Creation & Authentication

/**
 * Sign up a user for a given service
 * @param userName The account name of the new user
 * @param password The password for the new user
 * @param serverURL The URL for the service to add the user to. Note,
 *   this sets the root URL for all subsequent requests for a LuxeService
 *   instance until -signoutUserWithSuccess:failure: is invoked
 * @param success The callback block for a successful sign-up
 * @param failure The callback block for a failed sign-up
 * @return NSString identifier for the operation, suitable for cancelling with
 *   -cancelRequestWithIdentifier:
 */
- (NSString *)registerNewUserWithName:(NSString *)userName
                             password:(NSString *)password
                            serverURL:(NSURL *)serverURL
                              success:(LuxeServiceSuccess)success
                              failure:(LuxeServiceFailure)failure;

/**
 * Sign in an existing user
 * @param userName The account name of the user
 * @param password The password for the user
 * @param serverURL The URL for the service to authenticate with.  Note,
 *   this sets the root URL for all subsequent requests for a LuxeService
 *   instance until -signoutUserWithSuccess:failure: is invoked.
 * @param success The callback block for a successful sign-in
 * @param failure The callback block for a failed sign-in attempt
 * @return NSString identifier for the operation, suitable for canceling with
 *  -cancelRequestWithIdentifier:
 */
- (NSString *)signInWithUserName:(NSString *)userName
                        password:(NSString *)password
                       serverURL:(NSURL *)serverURL
                         success:(void(^)(LuxeUser *user))success
                         failure:(LuxeServiceFailure)failure;

/**
 * Signs out user with current server URL endpoint specified in either:
 * -registerNewUserWithName:password:serverURL:success:failure: 
 * or
 * -signInWithUserName:password:serverURL:success:failure.  After this
 * method is invoked, server URL endpoint is invalidated and invoking
 * any API methods other than sign-up or sign-in is not allowed.
 * @return NSString identifier for the operation, suitable for cancelling
 *   with -cancelRequestWithIdentifier:
 */
- (NSString *)signOutUserWithURL: (NSURL *)serverURL
                           success:(void(^)())success
                           failure:(LuxeServiceFailure)failure;

/**
 * Indicates if the user successfully authenticated
 */
-(BOOL)isUserSignedIn;

/**
 * Return the current user or nil if -isUserSignedIn returns NO
 */
- (LuxeUser *)currentUser;

/**
 * Current server the service instance is pointed at.  Returns nil if
 *   -isUserSignedIn returns NO
 */
- (NSURL *)serverRoot;

/**
 * Cancels the request matching the given identifier.  If the operation has
 *  already completed, the result is a no-op.  If no matching operation can
 *  be found, the result is a no-op.
 * @param identifier the ID of the request to cancel.
 */
- (void)cancelRequestWithIdentifier:(NSString *)identifier;

@end

@interface LuxeService (SubclassRequirements)

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(LuxeServiceSuccess)success
                           failure:(LuxeServiceFailure)failure;

- (void)cancelRequestWithIdentifier:(NSString *)identifier;

- (void)resendRequestsPendingAuthentication;

@end
