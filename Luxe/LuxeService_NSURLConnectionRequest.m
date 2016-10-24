//
//  LuxeService_NSURLConnectionRequest.m
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import "LuxeService_NSURLConnectionRequest.h"

#import "NSHTTPURLResponse+LuxeExtensions.h"

@interface LuxeService_NSURLConnectionRequest ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) LuxeServiceSuccess successCallback;
@property (nonatomic, copy) LuxeServiceFailure failureCallback;
@property (nonatomic, assign) NSInteger expectedStatusCode;
@property (nonatomic, assign) NSInteger actualStatusCode;
@property (nonatomic, weak) id<LuxeService_NSURLConnectionRequestDelegate> delegate;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation LuxeService_NSURLConnectionRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
             expectedStatusCode:(NSInteger)statusCode
                        success:(LuxeServiceSuccess)success
                        failure:(LuxeServiceFailure)failure
                       delegate:(id<LuxeService_NSURLConnectionRequestDelegate>)delegate
{
   if ((self = [super init])) {
      self.request = request;
      self.expectedStatusCode = statusCode;
      self.successCallback = success;
      self.failureCallback = failure;
      self.uniqueIdentifier = [[NSUUID UUID] UUIDString];
      self.delegate = delegate;
      
      [self initiateRequest];
   }
   
   return self;
}

- (void)initiateRequest
{
   self.response = nil;
   self.data = [NSMutableData data];
   self.actualStatusCode = NSNotFound;
   self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

- (void)cancel
{
   [self.connection cancel];
}

- (void)restart
{
   [self cancel];
   [self initiateRequest];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error
{
   NSURLRequest *request = [connection originalRequest];
   
   [connection cancel];
   
   NSLog(@"%@ %@ %li FAIL %@", [request HTTPMethod], [request URL], (long)self.expectedStatusCode, error);
   dispatch_async(dispatch_get_main_queue(), ^{
      self.failureCallback(error);
   });
   
   [self.delegate requestDidComplete:self];
}

#pragma mark - NSURLConnectionDataDelegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   self.response = response;
   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
   self.actualStatusCode = responseCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [self appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   NSURLRequest *request = [connection originalRequest];
   
   if ([self hasExpectedStatusCode]) {
      NSLog(@"%@ %@ %li SUCCESS", [request HTTPMethod], [request URL], (long)self.expectedStatusCode);

      dispatch_async(dispatch_get_main_queue(), ^{
         self.successCallback(self.data);
      });
      
   } else if(self.actualStatusCode == 401) {
      [self.delegate requestRequiredAuthentication:self];
      
   } else {
      NSLog(@"%@ %@ %li INVALID STATUS CODE", [request HTTPMethod], [request URL], (long)self.actualStatusCode);
      
      NSString *message = [NSString stringWithFormat:@"Unexpected error code: %li", (long)self.actualStatusCode];
      
      if(self.data) {
         NSError *jsonError = nil;
         id json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
         
         if(json && [json isKindOfClass:[NSDictionary class]]) {
            NSString *errorMessage = [(NSDictionary *)json valueForKey:@"error"];
            if(errorMessage) {
               message = errorMessage;
            }
         }
      }
      
      /*
      NSString *message = [(NSHTTPURLResponse *)self.response errorMessageWithData:self.data];
      NSError *error = [NSError errorWithDomain:@"LuxeService"
                                           code:self.actualStatusCode
                                       userInfo:@{ NSLocalizedDescriptionKey: message }];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         self.failureCallback(error);
      });
       */
   }
   
   [self.delegate requestDidComplete:self];
}

#pragma mark - Private helpers

- (void)appendData:(NSData *)data
{
   [self.data appendData:data];
}

- (BOOL)hasExpectedStatusCode
{
   if (self.actualStatusCode != NSNotFound) {
      return self.expectedStatusCode == self.actualStatusCode;
   }
   
   return NO;
}

@end
