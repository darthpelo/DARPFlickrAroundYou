//
//  DARPViewController.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 06/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "DARPViewController.h"
#import "DARPPhoto.h"

#import "DARPPhotosDownloadManager.h"
#import "MBProgressHUD.h"
#import "JPSThumbnailAnnotation.h"
#import "UIImageView+AFNetworking.h"

static double const kDARPMinDistance = 100.0;

@interface DARPViewController () <MKMapViewDelegate> {
    BOOL requestInProgress;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *lastUserLocation;

@end

@implementation DARPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma makr Private methods

- (void)updatePhotosList:(CLLocationCoordinate2D)newUserLocation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    requestInProgress = YES;
    
    __weak __typeof(self)weakSelf = self;
    [[DARPPhotosDownloadManager sharedManager] downloadPhotoAroundCoordinate:newUserLocation success:^(NSArray *list) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        requestInProgress = NO;
        
        [strongSelf.mapView addAnnotations:[strongSelf annotationsFromList:list]];
    } failure:^(NSError *error) {
        abort();
    }];
}

- (NSArray *)annotationsFromList:(NSArray *)photosList {
    NSMutableArray *annotations = [NSMutableArray new];
    
    for (int i = 0; i < photosList.count; i++) {
        DARPPhoto *photo = photosList[i];
        
        JPSThumbnail *thumb = [[JPSThumbnail alloc] init];
        thumb.coordinate = photo.photoCoordinate;
        
        if (photo.photoTumb != nil) {
            thumb.image = photo.photoTumb;
            
            [annotations addObject:[JPSThumbnailAnnotation annotationWithThumbnail:thumb]];
        }
    }

    return annotations;
}

/**
 * If distance from last user location is more than 100m, return YES
 */
- (BOOL)checkDistance:(CLLocationCoordinate2D)newUserLocation
{
    if (self.lastUserLocation == nil)
        return YES;
    
    CLLocation *currentLoc = [[CLLocation alloc] initWithLatitude:newUserLocation.latitude longitude:newUserLocation.longitude];
    
    CLLocationDistance distance = [self.lastUserLocation distanceFromLocation:currentLoc];
    
    if (distance > kDARPMinDistance && requestInProgress == NO) {
        return YES;
    }
    
    return NO;
}

#pragma mark - MKMapView delegate

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
{
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    
    if ([self checkDistance:location] == YES) {
        _lastUserLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        
        [self updatePhotosList:location];
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.002;
        span.longitudeDelta = 0.002;
        region.span = span;
        region.center = location;
        [aMapView setRegion:region animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation)
        return nil;
    
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    
    return nil;
}

@end
