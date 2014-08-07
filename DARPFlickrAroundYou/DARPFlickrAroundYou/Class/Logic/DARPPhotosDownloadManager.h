//
//  DARPPhotosDownloadManager.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 07/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@interface DARPPhotosDownloadManager : NSObject

+ (DARPPhotosDownloadManager *)sharedManager;

- (void)downloadPhotoAroundCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(NSArray *list))success failure:(void (^)(NSError *error))failure;;

@end
