//
//  LuxeUser.h
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import <Foundation/Foundation.h>

#import "LuxeSerializable.h"

/**
 * A constant string defining the JSON key to access the public ID of the user
 */
extern NSString * const LuxeUserPublicIDKey;

/**
 * A constant defining the JSON key to access the 'name' of the user
 */
extern NSString * const LuxeUserNameKey;

@interface LuxeUser : NSObject <LuxeSerializable>

/**
 * The unique id of the user, used to communicate with the server
 */
@property(nonatomic, copy, readonly) NSString *publicID;

/**
 * The name of the user
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Create a new instance from constitutent bits
 */
- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name;

/**
 * Create a new instance from a dictionary using LuxeUserPublicIDKey
 *  and LuxeUserNameKey keys
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Returns a dictionary representation of a user suitable
 *   for JSON serialization
 */
- (NSDictionary *)dictionaryRepresentation;
@end
