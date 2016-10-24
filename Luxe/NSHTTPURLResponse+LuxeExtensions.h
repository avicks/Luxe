//
//  NSHTTPURLResponse+LuxeExtensions.h
//  Luxe
//
//  Created by Alex Vickers on 3/18/16.
//
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (LuxeExtensions)

/**
 * Attempt to extract an error message from the given data object
 *  (assumes JSON payload), otherwise return default error message.
 */
- (NSString *)errorMessageWithData:(NSData *)data;

@end
