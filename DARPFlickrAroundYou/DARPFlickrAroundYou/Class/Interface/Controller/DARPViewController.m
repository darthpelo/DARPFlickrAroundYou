//
//  DARPViewController.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 06/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@import MapKit;

#import "DARPViewController.h"
#import "DARPPhoto+MKAnnotation.h"

#import "DARPPhotosDownloadManager.h"
#import "MBProgressHUD.h"

static double const kDARPMinDistance = 100.0;

@interface DARPViewController () <MKMapViewDelegate> {
    BOOL requestInProgress;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *lastUserLocation;
@property (strong, nonatomic) NSArray *photosList;
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
        
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        [strongSelf proccessAnnotations:list];
        
        requestInProgress = NO;
        
    } failure:^(NSError *error) {
        abort();
    }];
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

-(void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    } else {
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

- (void)proccessAnnotations:(NSArray *)list
{
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations:list];
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *reuseId = @"DARPViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if(!view)
    {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        if([mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)])
        {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        imageView.image = nil;
    }
    
    return view;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if([view.annotation respondsToSelector:@selector(thumbnail)])
        {
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
}

@end
