//
//  LuxeService_NSURLConnection.m
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import "LuxeService_NSURLConnection.h"

#import "LuxeService_SubclassMethods.h"
#import "LuxeUser.h"
#import "LuxeService_NSURLConnectionRequest.h"
#import "NSArray+Enumerable.h"

@interface LuxeService_NSURLConnection () <LuxeService_NSURLConnectionRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation LuxeService_NSURLConnection

- (id)init
{
   if((self = [super init]))
   {
      self.requestsPendingAuthentication = [NSMutableArray array];
   }
   
   return self;
}

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(LuxeServiceSuccess)success
                           failure:(LuxeServiceFailure)failure
{
   //NSMutableURLRequest *request = [self requestForURL:URL method:httpMethod bodyDict:bodyDict];
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
   [request setHTTPMethod:httpMethod];
   
   //for now, assume body content is always form-url encoded
   if(bodyDict) {
      [request setHTTPBody:[self formEncodedParameters:bodyDict]];
      [request addValue:@"application/x-www-form-urlencoded"
            forHTTPHeaderField:@"Content-Type"];
   }

   [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

   
   LuxeService_NSURLConnectionRequest *connectionRequest;
   connectionRequest = [[LuxeService_NSURLConnectionRequest alloc] initWithRequest:request
                                                                expectedStatusCode:expectedStatus
                                                                           success:success
                                                                           failure:failure
                                                                          delegate:self];
   
   NSString *connectionID = [connectionRequest uniqueIdentifier];
   [self.requests setObject:connectionRequest forKey:connectionID];
   return connectionID;
}

- (void)resendRequestsPendingAuthentication
{
   for(LuxeService_NSURLConnectionRequest *request in self.requestsPendingAuthentication) {
      [request restart];
   }
}

#pragma mark - Cancellation

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
   LuxeService_NSURLConnectionRequest *request = [self.requests objectForKey:identifier];
   if(request) {
      [request cancel];
      [self.requests removeObjectForKey:identifier];
   }
}

#pragma mark - Private helpers

- (NSData *)formEncodedParameters:(NSDictionary *)parameters
{
   NSArray *pairs = [parameters.allKeys mappedArrayWithBlock:^id(id obj) {
      return [NSString stringWithFormat:@"%@=%@",
              [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [parameters[obj] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   }];
   
   NSString *formBody = [pairs componentsJoinedByString:@"&"];
   
   return [formBody dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - LuxeService_NSURLConnectionRequestDelegate

- (void)requestDidComplete:(LuxeService_NSURLConnectionRequest *)request
{
   [self.requests removeObjectForKey:[request uniqueIdentifier]];
   [self.requestsPendingAuthentication removeObject:request];
}

- (void)requestRequiredAuthentication:(LuxeService_NSURLConnectionRequest *)request
{
   [self.requestsPendingAuthentication addObject:request];
   [[NSNotificationCenter defaultCenter] postNotificationName:LuxeServiceAuthRequiredNotification object:nil];
}

@end
