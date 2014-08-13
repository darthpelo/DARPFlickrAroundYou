//
//  Photo+MKAnnotation.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 11/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "Photo+MKAnnotation.h"

@implementation Photo (MKAnnotation)

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (UIImage *)thumbnail
{
    // Check if image is ready
    if (self.imageThumb == nil) {
        [self checkThumbnail:^(NSData *imageData) {
            self.imageThumb = imageData;
        }];
    }
    return [UIImage imageWithData:self.imageThumb];
}

#pragma mark - Private methods

- (void)checkThumbnail:(void(^)(NSData *imageData))block
{
    // Download image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *imageURL = [NSURL URLWithString:self.thumbURL];
                       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           block(imageData);
                       });
                   });
}

@end
