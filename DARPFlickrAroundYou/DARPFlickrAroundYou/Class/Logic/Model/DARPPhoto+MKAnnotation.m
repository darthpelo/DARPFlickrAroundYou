//
//  DARPPhoto+MKAnnotation.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 09/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPPhoto+MKAnnotation.h"

@implementation DARPPhoto (MKAnnotation)

- (CLLocationCoordinate2D)coordinate
{
    return self.photoCoordinate;
}

- (UIImage *)thumbnail
{
    if (self.photoTumb == nil) {
        [self checkThumbnail];
        return nil;
    }
    return self.photoTumb;
}

#pragma mark - Private methods

- (void)checkThumbnail
{
    // Download image
    if (self.photoTumb == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSURL *imageURL = [NSURL URLWithString:self.photoURL];
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               self.photoTumb = [UIImage imageWithData:imageData];
                               
                           });
                       });
        
    }
}

@end
