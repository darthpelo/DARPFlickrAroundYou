//
//  Photo.h
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 13/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * imageThumb;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * photoid;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * imageBig;
@property (nonatomic, retain) NSString * imageBigURL;

@end
