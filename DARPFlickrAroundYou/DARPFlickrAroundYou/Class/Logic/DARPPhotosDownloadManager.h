//
//  DARPPhotosDownloadManager.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 07/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@interface DARPPhotosDownloadManager : NSObject

+ (DARPPhotosDownloadManager *)sharedManager;

/**
 *  Given a couple of coordinate, return a list with principal photos around the position
 *
 *  @param coordinate A CLLocationCoordinate2D value
 *  @param radius     A valid radius used for geo queries, greater than zero and less than 20 miles (or 32 kilometers), for use with point-based geo queries. The default value is 5 (km).
 *  @param success    The block to be executed on the completion of a successful request. This block has no return value and takes an argument: the NSArray constructed from the response data of the request.
 *  @param failure    The block to be executed on the completion of an unsuccessful request. This block has no return value and takes an argument: the error that occurred during the request.
 */
- (void)downloadPhotoAroundCoordinate:(CLLocationCoordinate2D)coordinate
                               radius:(NSUInteger)radius
                              success:(void (^)(NSArray *list))success
                              failure:(void (^)(NSError *error))failure;;

@end
