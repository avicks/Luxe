//
//  NSArray+Enumerable.h
//  Luxe
//
//  Created by Alex Vickers on 3/21/16.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id(^)(id obj))block;

@end
