//
//  LuxeService_NSURLSession.m
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import "LuxeService_NSURLSession.h"

#import "LuxeService_NSURLSessionRequest.h"
#import "LuxeService_SubclassMethods.h"
#import "NSArray+Enumerable.h"

@interface LuxeService_NSURLSession () <LuxeService_NSURLSessionRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation LuxeService_NSURLSession

- (id)init
{
   if ((self = [super init])) {
      self.requests = [NSMutableDictionary dictionary];
      self.requestsPendingAuthentication = [NSMutableArray array];
   }
   
   return self;
}

# pragma mark - Subclass methods

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(LuxeServiceSuccess)success
                           failure:(LuxeServiceFailure)failure
{
   NSMutableURLRequest *request = [self requestForURL:URL
                                               method:httpMethod
                                             bodyDict:bodyDict];

   LuxeService_NSURLSessionRequest *sessionRequest;
   sessionRequest = [[LuxeService_NSURLSessionRequest alloc] initWithRequest:request
                                                                usingSession:[NSURLSession sharedSession]
                                                              expectedStatus:expectedStatus
                                                                     success:success
                                                                     failure:failure
                                                                    delegate:self];
   
   self.requests[sessionRequest.requestIdentifier] = sessionRequest;
   return sessionRequest.requestIdentifier;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
   LuxeService_NSURLSessionRequest *request = self.requests[identifier];
   if (request) {
      [request cancel];
      [self.requests removeObjectForKey:identifier];
   }
}

- (void)resendRequestsPendingAuthentication
{
   for (LuxeService_NSURLSessionRequest *request in self.requestsPendingAuthentication) {
      [request restart];
   }
}

#pragma mark - LuxeService_NSURLSessionRequestDelegate

- (void)sessionRequestDidComplete:(LuxeService_NSURLSessionRequest *)request
{
   [self.requests removeObjectForKey:request.requestIdentifier];
   [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestFailed:(LuxeService_NSURLSessionRequest *)request error:(NSError *)error
{
   [self.requests removeObjectForKey:request.requestIdentifier];
   [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestRequiresAuthentication:(LuxeService_NSURLSessionRequest *)request
{
   [self.requestsPendingAuthentication addObject:request];
   [[NSNotificationCenter defaultCenter] postNotificationName:LuxeServiceAuthRequiredNotification object:nil];
}

@end
