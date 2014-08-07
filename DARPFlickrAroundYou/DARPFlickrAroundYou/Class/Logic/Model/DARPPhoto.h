//
//  DARPPhoto.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 07/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DARPPhoto : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D photoCoordinate;
@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) UIImage *photoTumb;

@end
