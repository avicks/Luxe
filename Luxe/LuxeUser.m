//
//  LuxeUser.m
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import "LuxeUser.h"

NSString * const LuxeUserPublicIDKey = @"id";
NSString * const LuxeUserNameKey = @"name";

@interface LuxeUser ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;

@end
@implementation LuxeUser

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name {
   if((self = [super init])) {
      self.publicID = publicID;
      self.name = name;
   }
   
   return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
   return [self initWithPublicID:dict[LuxeUserPublicIDKey] name:dict[LuxeUserNameKey]];
}

- (NSDictionary *)dictionaryRepresentation {
   return @{
            LuxeUserPublicIDKey : self.publicID,
            LuxeUserNameKey : self.name
            };
}

- (NSString *)description
{
   return [NSString stringWithFormat:@"<%@: 0x%x publicID=%@ name=%@>",
           NSStringFromClass([self class]),
           (unsigned int)self,
           self.publicID,
           self.name];
}
@end
