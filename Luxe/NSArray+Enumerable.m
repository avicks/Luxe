//
//  NSArray+Enumerable.m
//  Luxe
//
//  Created by Alex Vickers on 3/21/16.
//
//

#import "NSArray+Enumerable.h"

@implementation NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id (^)(id))block {
   NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.count];
   
   for (id obj in self) {
      [temp addObject:block(obj)];
   }
   
   return temp;
}

@end
