//
//  DARPPhotosDownloadManager.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 07/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPPhotosDownloadManager.h"

#import "VEFlickrConnection.h"

#import "DARPPhoto.h"

#import "UIImageView+AFNetworking.h"

@interface DARPPhotosDownloadManager ()
@property (strong, nonatomic) NSMutableArray *photoList;
@property (strong, nonatomic) NSMutableDictionary *photoIdMap;
@end

@implementation DARPPhotosDownloadManager

+ (DARPPhotosDownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static DARPPhotosDownloadManager *manager;
    dispatch_once(&once, ^ { manager = [[DARPPhotosDownloadManager alloc] init]; });
    return manager;
}

- (id)init
{
    if (self = [super init]) {
        _photoList = [[NSMutableArray alloc] init];
        _photoIdMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Public methods
- (void)downloadPhotoAroundCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(NSArray *list))success failure:(void (^)(NSError *error))failure;
{
    // Search photos around user location (radius 2 km accurancy 8)
    [[VEFlickrConnection flickrManager] searchPhotosWithLocation:coordinate
                                                         success:^(NSArray *list) {
                                                             // Collect information about photos: coordinate and small thumb
                                                             [self collectPhotoInformation:list success:^(NSArray *list) {
                                                                 success(list);
                                                             }];
                                                         } failure:^(NSError *error) {
                                                             NSLog(@"%@", error.debugDescription);
                                                         }];
}

#pragma mark - Private methods

- (void)collectPhotoInformation:(NSArray *)list success:(void(^)(NSArray *list))success
{
    NSUInteger totalPhotos = list.count;
    
    __block NSMutableArray *blockPhotoList = self.photoList;
    __block NSMutableDictionary *blockPhotoIdMap = self.photoIdMap;
    
    for (int i = 0; i < totalPhotos; i++) {
        NSDictionary *element = list[i];
        
        if (blockPhotoIdMap[element[@"id"]] == nil) {
            __block DARPPhoto *photo = [DARPPhoto new];
            
            photo.photoId = element[@"id"];
            
            [blockPhotoIdMap setObject:photo.photoId forKey:photo.photoId];
            
            // Request photo's coordinate
            [[VEFlickrConnection flickrManager] getPhotoCoordinate:photo.photoId
                                                           success:^(CLLocationCoordinate2D coordinate) {
                                                               photo.photoCoordinate = coordinate;
                                                               
                                                               // Request photo's thumb
                                                               [[VEFlickrConnection flickrManager] getPhotoThumb:photo.photoId success:^(NSDictionary *responseData) {
                                                                   /**
                                                                    { "label": "Square", "width": 75, "height": 75, "source": "https:\/\/farm3.staticflickr.com\/2900\/14300335396_3e4e9ffbd8_s.jpg", "url": "https:\/\/www.flickr.com\/photos\/darthpelo02\/14300335396\/sizes\/sq\/", "media": "photo" }
                                                                    */
                                                                   photo.photoURL = responseData[@"source"];
                                                                   
                                                                   // Download image
                                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                                  ^{
                                                                                      NSURL *imageURL = [NSURL URLWithString:photo.photoURL];
                                                                                      NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                                                                                      
                                                                                      //This is your completion handler
                                                                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                                                                          photo.photoTumb = [UIImage imageWithData:imageData];
                                                                                      });
                                                                                  });
                                                                   
                                                                   // Add DARPPhoto to the final list
                                                                   [blockPhotoList addObject:photo];
                                                                   
                                                                   if (blockPhotoList.count == totalPhotos) {
                                                                       success(blockPhotoList);
                                                                   }
                                                                   
                                                               } failure:^(NSError *error) {
                                                                   NSLog(@"%@", error.debugDescription);
                                                               }];
                                                           } failure:^(NSError *error) {
                                                               NSLog(@"%@", error.debugDescription);
                                                           }];
        }
    }
}

@end
