//
//  NSHTTPURLResponse+LuxeExtensions.m
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import "NSHTTPURLResponse+LuxeExtensions.h"

@implementation NSHTTPURLResponse (LuxeExtensions)

- (NSString *)errorMessageWithData:(NSData *)data
{
   NSString *message = [NSString stringWithFormat:@"Unexpected response code: %li", (long)self.statusCode];
   
   if (data) {
      NSError *jsonError = nil;
      id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
      if( json && [json isKindOfClass:[NSDictionary class]]) {
         NSString *errorMessage = [(NSDictionary *)json valueForKey:@"error"];
         if(errorMessage) {
            message = errorMessage;
         }
      }
   }
   
   return message;
}

@end
