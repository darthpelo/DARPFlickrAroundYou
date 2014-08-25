//
//  ViewController.swift
//  DARPFlickrAroundYouSwift
//
//  Created by Alessio Roberto on 24/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var lastUserLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    /*
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

    */
    
    func checkDistance(userLocation: CLLocationCoordinate2D) -> (Bool) {
        
        let lat = lastUserLocation?.latitude
        let lon = lastUserLocation?.longitude
        
        let currentLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let lastLoc = CLLocation(latitude: lat!, longitude: lon!)
        
        if lastLoc.distanceFromLocation(currentLoc) > 50.0 {
            return true
        }
        return false
    }

    // MARK: - MKMapView delegate
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        var location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        lastUserLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if checkDistance(location) == true {
            
            var region: MKCoordinateRegion
            
            var span = MKCoordinateSpanMake(0.002, 0.002)
            
            region = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
        }
    }

}

