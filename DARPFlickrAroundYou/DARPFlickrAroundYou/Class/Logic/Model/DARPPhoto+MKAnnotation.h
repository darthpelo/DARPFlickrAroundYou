//
//  DARPPhoto+MKAnnotation.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 09/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPPhoto.h"
#import <MapKit/MapKit.h>

@interface DARPPhoto (MKAnnotation) <MKAnnotation>

- (UIImage *)thumbnail;

@end
