//
//  LuxeTrip.h
//  Luxe
//
//  Created by Alex Vickers on 3/30/16.
//
//

#import <Foundation/Foundation.h>

#import "LuxeSerializable.h"

/**
 * The key for the publicID property
 */
extern NSString * const LuxeTripPublicIDKey;

/**
 * The key for the payment ID property
 */
extern NSString * const LuxeTripPaymentIDKey;

/**
 * The key for the trip date property
 */
extern NSString * const LuxeTripDateKey;

/**
 * The key for the pick up location property
 */
extern NSString * const LuxeTripPickUpKey;

/**
 * The key for the drop off location property
 */
extern NSString * const LuxeTripDropOffKey;

/**
 * The key for the passenger count property
 */
extern NSString * const LuxeTripPassengerKey;

/**
 * The key for the children count property
 */
extern NSString * const LuxeTripChildrenKey;

/**
 * The key for the return trip boolean property
 */
extern NSString * const LuxeTripReturnKey;

@interface LuxeTrip : NSObject <LuxeSerializable>

@end
