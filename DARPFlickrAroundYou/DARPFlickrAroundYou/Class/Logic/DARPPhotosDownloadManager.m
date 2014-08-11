//
//  DARPPhotosDownloadManager.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 07/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPAppDelegate.h"

#import "DARPPhotosDownloadManager.h"

#import "DARPPhoto.h"
#import "Photo.h"

#import "VEFlickrConnection.h"

@interface DARPPhotosDownloadManager ()
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
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
        DARPAppDelegate *appDelegate = (DARPAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    
    return self;
}

#pragma mark - Public methods
- (void)downloadPhotoAroundCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSUInteger)radius success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    // Search photos around user location
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue,^{
        [[VEFlickrConnection flickrManager] searchPhotosWithLocation:coordinate radius:radius
                                                             success:^(NSArray *list) {
                                                                 // Collect information about photos: coordinate and small thumb
                                                                 [self collectPhotoInformation:list success:^(NSArray *list) {
                                                                     success(list);
                                                                 }];
                                                             } failure:^(NSError *error) {
                                                                 NSLog(@"%@", error.debugDescription);
                                                             }];
    });
}

#pragma mark - Private methods

- (void)collectPhotoInformation:(NSArray *)list success:(void(^)(NSArray *list))success
{
    __block NSUInteger totalPhotos = list.count;
    __block NSMutableArray *blockPhotoList = [NSMutableArray new];
    
    for (int i = 0; i < list.count; i++) {
        NSDictionary *element = list[i];
        
        Photo *photo = nil;
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"photoid = %@", element[@"id"]];
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || [matches count] > 1) {
            // Handle error
        } else if(![matches count]) {
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            
            photo.photoid = element[@"id"];
            
            if (element[@"title"]) {
                photo.title = element[@"title"];
            }
            
            // Request photo's coordinate
            [[VEFlickrConnection flickrManager] getPhotoCoordinate:photo.photoid
                                                           success:^(CLLocationCoordinate2D coordinate) {
                                                               photo.latitude = [NSNumber numberWithDouble:coordinate.latitude];
                                                               photo.longitude = [NSNumber numberWithDouble:coordinate.longitude];
                                                               
                                                               // Add DARPPhoto to the final list
                                                               [blockPhotoList addObject:photo];
                                                               
                                                               NSLog(@"Photo %d from Flicrk server", totalPhotos);
                                                               
                                                               totalPhotos--;
                                                               
                                                               if (totalPhotos == 0) {
                                                                   success(blockPhotoList);
                                                               }
                                                               
                                                               // Request photo's thumb URL
                                                               [[VEFlickrConnection flickrManager] getPhotoThumb:photo.photoid success:^(NSDictionary *responseData) {
                                                                   /**
                                                                    { "label": "Square", "width": 75, "height": 75, "source": "https:\/\/farm3.staticflickr.com\/2900\/14300335396_3e4e9ffbd8_s.jpg", "url": "https:\/\/www.flickr.com\/photos\/darthpelo02\/14300335396\/sizes\/sq\/", "media": "photo" }
                                                                    */
                                                                   
                                                                   photo.thumbURL = responseData[@"source"];
                                                                   
                                                                   // Download image
                                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                                  ^{
                                                                                      NSURL *imageURL = [NSURL URLWithString:photo.thumbURL];
                                                                                      NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                                                                                      
                                                                                      //This is your completion handler
                                                                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                                                                          photo.image = imageData;
                                                                                          
                                                                                      });
                                                                                  });
                                                               } failure:^(NSError *error) {
                                                                   NSLog(@"%@", error.debugDescription);
                                                               }];
                                                           } failure:^(NSError *error) {
                                                               NSLog(@"%@", error.debugDescription);
                                                           }];
            
        } else {
            photo = [matches lastObject];
            
            // Add DARPPhoto to the final list
            [blockPhotoList addObject:photo];
            
            NSLog(@"Photo %d from DB", totalPhotos);
            
            totalPhotos--;
            
            if (totalPhotos == 0) {
                success(blockPhotoList);
            }
        }
    }
}

@end
