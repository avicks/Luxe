//
//  LuxeService.m
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import "LuxeService.h"

#import "LuxeUser.h"
#import "NSArray+Enumerable.h"
#import "LuxeService_NSURLConnection.h"
#import "LuxeService_NSURLSession.h"

NSString * const LuxeServiceAuthRequiredNotification = @"LuxeServiceAuthRequiredNotification";

/**
 * The user-defaults key for the URL of the last server the user authenticated
 */
static NSString * const LuxeLastServerURLKey = @"LastServerURL";

/**
 * The user-defaults key for the user identifier
 */
static NSString * const LuxeUserIdentifierKey = @"UserIdentifier";

/**
 * The user-defaults key for the current user
 */
static NSString * const LuxeCurrentUserKey = @"CurrentUser";

static LuxeService *SharedInstance;

@interface LuxeService ()

@property (nonatomic, strong) LuxeUser *currentUser;
@property (nonatomic, strong) NSURL *tempServerRoot;
@property (nonatomic, strong) NSURL *serverRoot;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end


@implementation LuxeService

+ (LuxeService *)sharedInstance
{
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      SharedInstance = [[LuxeService_NSURLSession alloc] init];
   });
   
   return SharedInstance;
}

- (instancetype)init
{
   if((self = [super init])) {
      self.requests = [NSMutableDictionary dictionary];
      
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSString *serverRootString = [defaults stringForKey:LuxeLastServerURLKey];
      if(serverRootString) {
         self.serverRoot = [NSURL URLWithString:serverRootString];
      }
      
      NSDictionary *userDict = [defaults objectForKey:LuxeCurrentUserKey];
      if (userDict) {
         self.currentUser = [[LuxeUser alloc] initWithDictionary:userDict];
      }
   }
   
   return self;
}

#pragma mark - User Information Requests
-(NSString *)getTripHistory:(NSString *)userID
                    success:(LuxeServiceSuccess)success
                    failure:(LuxeServiceFailure)failure
{
   NSDictionary *params = @{
                            @"user_id": userID
                            };
   return [self submitPOSTPath:@"php/get_bookings.php"
                          body:params
                expectedStatus:200
                       success:^(NSData *data) {
                          NSError *error = nil;
                          
                          NSData *tripData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                          //NSLog(@"%@",tripData);
                          
                          NSArray *tripArray =
                          [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                          
                          if(data) {
                             //NSLog(@"%@",tripDict);
                             
                             if(success != NULL) {
                                success(data);
                             }
                          } else {
                             if (failure != NULL) {
                                failure(error);
                             }
                          }
                       }
                       failure:^(NSError *error) {
                          if(failure != NULL) {
                             failure(error);
                          }
                       }];
}


#pragma mark - User Authentication
- (NSString *)registerNewUserWithName:(NSString *)userName
                             password:(NSString *)password
                            serverURL:(NSURL *)serverURL
                              success:(LuxeServiceSuccess)success
                              failure:(LuxeServiceFailure)failure
{
   self.tempServerRoot = serverURL;
   NSDictionary *params = @{
                            @"email": userName,
                            @"p": password
                            };
   
   return [self submitPOSTPath:@"php/registerAPP.php" body:params expectedStatus:200 success:^(NSData *data) {
      NSError *error = nil;
      if(data) {
         NSLog(@"@%", data);
         if(success != NULL) {
            success(data);
         }
      } else {
         NSLog(@"no data!");

         if(failure != NULL) {
            failure(error);
         }
      }
   } failure:^(NSError *error) {
      NSLog(@"error!!");
      NSLog(@"%@",[error localizedDescription]);

      if(failure != NULL) {
         failure(error);
      }
   }];
}

- (NSString *)signInWithUserName:(NSString *)userName
                        password:(NSString *)password
                       serverURL:(NSURL *)serverURL
                         success:(void (^)(LuxeUser *))success
                         failure:(LuxeServiceFailure)failure
{
   self.tempServerRoot = serverURL;
   NSDictionary *params = @{
                            @"email": userName,
                            @"p": password
                            };
   return [self submitPOSTPath:@"php/authenticate.php"
                          body:params
                expectedStatus:200
                       success:^(NSData *data) {
                          NSError *error = nil;
                          NSDictionary *userDict =
                          [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                          
                          if(userDict && [userDict isKindOfClass:[NSDictionary class]]) {
                             self.currentUser = [[LuxeUser alloc] initWithDictionary:userDict];
                             self.tempServerRoot = nil;
                             self.serverRoot = serverURL;
                             
                             [self persistServerRootAndUserIdentifier];
                             
                             if(success != NULL) {
                                success(self.currentUser);
                             }
                             
                             [self resendRequestsPendingAuthentication];
                          }
                          else {
                             //NSLog(@"%@", error);
                             if (failure != NULL) {
                                failure(error);
                             }
                          }
                       }
                       failure:^(NSError *error) {
                          self.tempServerRoot = nil;
                          if(failure != NULL) {
                             failure(error);
                          }
                       }];
}

- (NSString *)signOutUserWithURL:(NSURL *)serverURL
                         success:(void (^)())success
                         failure:(LuxeServiceFailure)failure
{
   self.tempServerRoot = serverURL;
   NSDictionary *params = @{};
   
   return [self submitPOSTPath:@"php/logoutAPP.php"
                          body:params
                expectedStatus:200
                       success:^(NSData *data) {
                          NSError *error = nil;
                          NSDictionary *returnDict =
                          [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                          
                          NSLog(@"%@",returnDict);
                          
                          self.serverRoot = nil;
                          self.currentUser = nil;
                          
                          [self persistServerRootAndUserIdentifier];
                          
                          if(success != NULL) {
                             success();
                          }
                          
                       }
                       failure:^(NSError *error) {
                          self.tempServerRoot = nil;
                          if(failure != NULL) {
                             failure(error);
                          }
                       }];
}

- (BOOL) isUserSignedIn
{
   return self.serverRoot != nil;
}

#pragma mark - Abstract methods
- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(LuxeServiceSuccess)success
                           failure:(LuxeServiceFailure)failure
{
   NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
   return nil;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
   NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

- (void)resendRequestsPendingAuthentication
{
   NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

#pragma mark - Request Helpers

- (void)persistServerRootAndUserIdentifier
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:self.serverRoot.absoluteString forKey:LuxeLastServerURLKey];
   [defaults setObject:self.currentUser.publicID forKey:LuxeUserIdentifierKey];
   [defaults setObject:[self.currentUser dictionaryRepresentation] forKey:LuxeCurrentUserKey];
   [defaults synchronize];
}

- (NSURL *)URLWithPath:(NSString *)path
{
   NSURL *root = self.serverRoot ?: self.tempServerRoot;
   NSAssert(root != nil, @"Cannot make requests if neither serverRoot or tempServerRoot are nil");
   return [NSURL URLWithString:path relativeToURL:root];
}

- (NSString *)submitGETPath:(NSString *)path
                    success:(LuxeServiceSuccess)success
                    failure:(LuxeServiceFailure)failure
{
   NSURL *URL = [self URLWithPath:path];
   return [self submitRequestWithURL:URL
                              method:@"GET"
                                body:nil
                      expectedStatus:200
                             success:success
                             failure:failure];
}

- (NSString *)submitDELETEPath:(NSString *)path
                       success:(LuxeServiceSuccess)success
                       failure:(LuxeServiceFailure)failure
{
   NSURL *URL = [self URLWithPath:path];
   return [self submitRequestWithURL:URL
                              method:@"DELETE"
                                body:nil
                      expectedStatus:200
                             success:success
                             failure:failure];
}

- (NSString *)submitPUTPath:(NSString *)path
                       body:(NSDictionary *)bodyDict
             expectedStatus:(NSInteger)expectedStatus
                    success:(LuxeServiceSuccess)success
                    failure:(LuxeServiceFailure)failure
{
   NSURL *URL = [self URLWithPath:path];
   return [self submitRequestWithURL:URL
                              method:@"PUT"
                                body:bodyDict
                      expectedStatus:expectedStatus
                             success:success
                             failure:failure];
}

- (NSString *)submitPOSTPath:(NSString *)path
                        body:(NSDictionary *)bodyDict
              expectedStatus:(NSInteger)expectedStatus
                     success:(LuxeServiceSuccess)success
                     failure:(LuxeServiceFailure)failure
{
   NSURL *URL = [self URLWithPath:path];
   return [self submitRequestWithURL:URL
                              method:@"POST"
                                body:bodyDict
                      expectedStatus:expectedStatus
                             success:success
                             failure:failure];
}

-(NSData *)formEncodedParameters:(NSDictionary *)parameters
{
   NSArray *pairs = [parameters.allKeys mappedArrayWithBlock:^id(id obj) {
      return [NSString stringWithFormat:@"%@=%@",
              [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [parameters[obj] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   }];
   
   NSString *formBody = [pairs componentsJoinedByString:@"&"];
   return [formBody dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)URL
                                method:(NSString *)httpMethod
                              bodyDict:(NSDictionary *)bodyDict
{
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
   [request setHTTPMethod:httpMethod];
   
   // For now, assume body content is always form-urlencoded
   if (bodyDict) {
      [request setHTTPBody:[self formEncodedParameters:bodyDict]];
      [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
   }
   
   [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
   return request;
}

@end
