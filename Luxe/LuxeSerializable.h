//
//  LuxeSerializable.h
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//

#import <Foundation/Foundation.h>

@protocol LuxeSerializable <NSObject>

/**
 * Initialize a new instance based on the properties and structure
 *   of the given dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Return a dictinoary representing the data and structure of this
 *  object.  This is effectively the inverse of -initWithDictionary
 */
- (NSDictionary *)dictionaryRepresentation;

@end