//
//  LuxeService_NSURLSessionRequest.m
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import "LuxeService_NSURLSessionRequest.h"

#import "NSHTTPURLResponse+LuxeExtensions.h"

@interface LuxeService_NSURLSessionRequest ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSString *requestIdentifier;

@end

@implementation LuxeService_NSURLSessionRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
                   usingSession:(NSURLSession *)session
                 expectedStatus:(NSInteger)expectedStatus
                        success:(LuxeServiceSuccess)success
                        failure:(LuxeServiceFailure)failure
                       delegate:(id<LuxeService_NSURLSessionRequestDelegate>)delegate
{
   if((self = [super init])) {
      self.URLRequest = request;
      self.session = session;
      self.expectedStatus = expectedStatus;
      self.successBlock = success;
      self.failureBlock = failure;
      self.delegate = delegate;
      
      self.requestIdentifier = [[NSUUID UUID] UUIDString];
      self.task = [self createDataTask];
      [self.task resume];
   }
   
   return self;
}

- (void)cancel
{
   [self.task cancel];
   self.task = nil;
}

-(void)restart
{
   [self cancel];
   self.task = [self createDataTask];
   [self.task resume];
}

#pragma mark - Private helpers

- (NSURLSessionDataTask *)createDataTask
{
   __weak typeof(self) weakSelf = self;
   NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
      NSMutableURLRequest *mutableRequest = (NSMutableURLRequest *)weakSelf.URLRequest;
      
      if(HTTPResponse.statusCode == weakSelf.expectedStatus) {
         NSLog(@"%@ %@ %li SUCCESS",
               [mutableRequest HTTPMethod], [mutableRequest URL], (long)weakSelf.expectedStatus);
         
         dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.successBlock(data);
            [weakSelf.delegate sessionRequestDidComplete:weakSelf];
         });
      } else if(HTTPResponse.statusCode == 401) {
         dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.successBlock(data);
            [weakSelf.delegate sessionRequestRequiresAuthentication:weakSelf];
         });
      } else {
         NSLog(@"%@ %@ %li INVALID STATUS CODE",
               [mutableRequest HTTPMethod], [mutableRequest URL], (long)HTTPResponse.statusCode);
         
         NSString *message = [HTTPResponse errorMessageWithData:data];
         if(message == (id)[NSNull null] || message.length == 0) {
            NSError *error = [NSError errorWithDomain:@"LuxeService"
                                                 code:HTTPResponse.statusCode
                                             userInfo:@{ NSLocalizedDescriptionKey: @"No connection." }];
         } else {
            NSError *error = [NSError errorWithDomain:@"LuxeService"
                                                 code:HTTPResponse.statusCode
                                             userInfo:@{ NSLocalizedDescriptionKey: message }];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.failureBlock(error);
            [weakSelf.delegate sessionRequestFailed:weakSelf error:error];
         });
      }
   }];
   
   return task;
}

@end
