//
//  VEFlickrConnection.h
//  Veespo
//
//  Created by Alessio Roberto on 05/03/14.
//  Copyright (c) 2014 Veespo Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEFlickrConnection : NSObject

+ (VEFlickrConnection *)flickrManager;

/**
 *    Return list of all photos in a radius of 10km around a couple of coordinate. https://www.flickr.com/services
 *
 *    @param location   A CLLocation value
 *    @param success A block
 *    @param failure A block
 */
- (void)searchPhotosWithLocation:(CLLocationCoordinate2D)location
                          radius:(NSUInteger)radius
                         success:(void (^)(NSArray *list))success
                         failure:(void (^)(NSError *error))failure;

/**
 *    Return photo coordinate. https://www.flickr.com/services
 *
 *    @param location   The photo id
 *    @param success A block
 *    @param failure A block
 */
- (void)getPhotoCoordinate:(NSString *)photoId
                   success:(void(^)(CLLocationCoordinate2D coordinate))success
                   failure:(void(^)(NSError *error))failure;

/**
 *    Return photos url. https://www.flickr.com/services
 *
 *    @param photoid The photo id
 *    @param success A block
 *    @param failure A block
 */
- (void)getPhotoThumb:(NSString *)photoid
              success:(void (^)(NSDictionary *responseData))success
              failure:(void (^)(NSError *error))failure;

@end
