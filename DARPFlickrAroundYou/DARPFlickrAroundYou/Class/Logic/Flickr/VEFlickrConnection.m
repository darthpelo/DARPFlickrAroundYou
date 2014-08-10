//
//  VEFlickrConnection.m
//  Veespo
//
//  Created by Alessio Roberto on 05/03/14.
//  Copyright (c) 2014 Veespo Ltd. All rights reserved.
//

#import "VEFlickrConnection.h"

#import "DARPConstants.h"

#import "AFNetworking.h"

@interface VEFlickrConnection ()
@property (nonatomic, strong) NSDictionary *keys;
@end

@implementation VEFlickrConnection

// Get list photos in a set http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=d35af515af4b9d496fb6fbf9a11c517c&photoset_id=72157634258095601&format=json&nojsoncallback=1

// Get photo size http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=d35af515af4b9d496fb6fbf9a11c517c&photo_id=12417978764&format=json&nojsoncallback=1

// Search photos with lat/long https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ccb9a0e7a51a442bc070af51759c9c74&accuracy=4&lat=42.783333&lon=12.6&radius=10&format=json&nojsoncallback=1&auth_token=72157646221538801-24dbfc99280cfe8f&api_sig=9614e88a8a21871ff9a34640b408024f

#pragma mark - Singleton init
+ (VEFlickrConnection *)flickrManager
{
    static dispatch_once_t once;
    static VEFlickrConnection *manager;
    dispatch_once(&once, ^ { manager = [[VEFlickrConnection alloc] init]; });
    return manager;
}

/**
 * Caricamento file con chiavi API Flickr
 */
- (id)init
{
    if (self = [super init]) {
        NSString *keysPath = [[NSBundle mainBundle] pathForResource:kDARPKeysFileName ofType:@"plist"];
        if (!keysPath) {
            NSLog(@"To use API make sure you have a API-Keys.plist with the Identifier in your project");
            abort();
        }
        
        NSDictionary *tmpKeys = [NSDictionary dictionaryWithContentsOfFile:keysPath];
        _keys = [[NSDictionary alloc] initWithDictionary:tmpKeys copyItems:YES];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)searchPhotosWithLocation:(CLLocationCoordinate2D)location radius:(NSUInteger)radius success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSString *accuracy = @"11";
    
    NSString *perpage;
    
    switch (radius) {
        case 1:
            perpage = @"20";
            break;
            
        case 2:
            perpage = @"50";
            break;
            
        case 3:
            perpage = @"70";
            break;
        
        case 4:
            perpage = @"100";
            break;
        
        case 5:
            perpage = @"160";
            break;
            
        case 6:
            perpage = @"200";
            break;
            
        default:
            perpage = @"300";
            break;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&accuracy=%@&lat=%f&lon=%f&radius=%@&per_page=%@&format=json&nojsoncallback=1",
                        self.keys[kDARPFlickrApiKey],
                        accuracy,
                        location.latitude,
                        location.longitude,
                        [NSString stringWithFormat:@"%d", radius],
                        perpage
                        ];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *photos = responseObject[@"photos"][@"photo"];
        
        success(photos);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getPhotoCoordinate:(NSString *)photoId
                   success:(void(^)(CLLocationCoordinate2D coordinate))success
                   failure:(void(^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1",
                        self.keys[kDARPFlickrApiKey],
                        photoId
                        ];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *location = responseObject[@"photo"][@"location"];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location[@"latitude"] doubleValue], [location[@"longitude"] doubleValue]);
        
        success(coordinate);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        failure(error);
    }];
}

- (void)getPhotoThumb:(NSString *)photoid success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&photo_id=%@&format=json&nojsoncallback=1",
                        self.keys[kDARPFlickrApiKey],
                        photoid
                        ];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"sizes"][@"size"];
        // Pass only the Square version of the photo
        success([list objectAtIndex:0]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        failure(error);
    }];
}

@end
