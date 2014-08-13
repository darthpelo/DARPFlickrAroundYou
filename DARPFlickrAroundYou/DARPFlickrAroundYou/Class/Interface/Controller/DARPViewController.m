//
//  DARPViewController.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 06/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@import MapKit;

#import "DARPViewController.h"
#import "Photo+MKAnnotation.h"
#import "DARPDetailViewController.h"

#import "DARPPhotosDownloadManager.h"
#import "MBProgressHUD.h"

static double const kDARPMinDistance = 50.0;

@interface DARPViewController () <MKMapViewDelegate>

@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;
@property (nonatomic, assign) BOOL requestInProgress;
@property (nonatomic, assign) CLLocationCoordinate2D lastUserLocation;
@property (nonatomic, strong) NSArray *photosList;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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

#pragma mark - Private methods

- (void)updatePhotosList:(CLLocationCoordinate2D)newUserLocation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.requestInProgress = YES;
    
    NSUInteger radius = 2;
    /*
    NSLog(@"%f", self.mapView.region.span.latitudeDelta);
    
    if (self.mapView.region.span.latitudeDelta > 0.002 && self.mapView.region.span.latitudeDelta < 0.003) {
        radius = 2;
    } else if (self.mapView.region.span.latitudeDelta > 0.003 && self.mapView.region.span.latitudeDelta < 0.004) {
        radius = 3;
    } else if (self.mapView.region.span.latitudeDelta > 0.004 && self.mapView.region.span.latitudeDelta < 0.005) {
        radius = 4;
    } else if (self.mapView.region.span.latitudeDelta > 0.005 && self.mapView.region.span.latitudeDelta < 0.007) {
        radius = 5;
    } else if (self.mapView.region.span.latitudeDelta > 0.007) {
        radius = 6;
    }
     */
    __weak __typeof(self)weakSelf = self;
    [[DARPPhotosDownloadManager sharedManager] downloadPhotoAroundCoordinate:newUserLocation radius:radius success:^(NSArray *list) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf proccessAnnotations:list];
        
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        self.requestInProgress = NO;
        
    } failure:^(NSError *error) {
        abort();
    }];
}

/**
 * If distance from last user location is more than 100m, return YES
 */
- (BOOL)checkDistance:(CLLocationCoordinate2D)newUserLocation
{
    CLLocation *currentLoc = [[CLLocation alloc] initWithLatitude:newUserLocation.latitude longitude:newUserLocation.longitude];
    CLLocation *lastLoc = [[CLLocation alloc] initWithLatitude:self.lastUserLocation.latitude longitude:self.lastUserLocation.longitude];
    CLLocationDistance distance = [lastLoc distanceFromLocation:currentLoc];
    
    if (distance > kDARPMinDistance && self.requestInProgress == NO) {
        return YES;
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        Photo *photo = self.mapView.selectedAnnotations.lastObject;
        DARPDetailViewController *controller = (DARPDetailViewController *)[[segue destinationViewController] topViewController];
        [controller setPhoto:photo];
    }
}
#pragma mark MKAnnotations
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
//    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations:list];
}

- (void)selectAnnotation:(id)sender
{
    [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

#pragma mark - MKMapView delegate

/*
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	UIView* view = mapView.subviews.firstObject;
	
	//	Look through gesture recognizers to determine
	//	whether this region change is from user interaction
	for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
	{
		//	The user caused of this...
		if(recognizer.state == UIGestureRecognizerStateBegan
		   || recognizer.state == UIGestureRecognizerStateEnded)
		{
			self.nextRegionChangeIsFromUserInteraction = YES;
			break;
		}
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if(self.nextRegionChangeIsFromUserInteraction)
	{
		self.nextRegionChangeIsFromUserInteraction = NO;
		
		if (self.requestInProgress == NO && mapView.region.span.latitudeDelta > 0.002) {
            [self updatePhotosList:self.lastUserLocation];
        }
	}
}
 */

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
{
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    
    if ([self checkDistance:location] == YES) {
        self.lastUserLocation = location;
        
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
    if(!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        view.image = [UIImage imageNamed:@"pin"];
        view.calloutOffset = CGPointMake(0, 0);
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [button addTarget:self
                   action:@selector(selectAnnotation:) forControlEvents:UIControlEventTouchUpInside];
        view.rightCalloutAccessoryView = button;
    }
    
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        imageView.image = nil;
        
        // Start download image
        if([view.annotation respondsToSelector:@selector(thumbnail)]) {
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
    
    return view;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if([view.annotation respondsToSelector:@selector(thumbnail)]) {
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
}

@end
