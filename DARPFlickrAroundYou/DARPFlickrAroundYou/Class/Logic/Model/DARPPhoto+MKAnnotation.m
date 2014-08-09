//
//  DARPPhoto+MKAnnotation.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 09/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPPhoto+MKAnnotation.h"

@implementation DARPPhoto (MKAnnotation)

-(CLLocationCoordinate2D)coordinate
{
    return self.photoCoordinate;
}

-(UIImage *)thumbnail
{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoURL]]];
}

@end
