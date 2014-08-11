//
//  Photo+MKAnnotation.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 11/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@import Foundation;
@import MapKit;

#import "Photo.h"

@interface Photo (MKAnnotation) <MKAnnotation>

- (UIImage *)thumbnail;

@end
