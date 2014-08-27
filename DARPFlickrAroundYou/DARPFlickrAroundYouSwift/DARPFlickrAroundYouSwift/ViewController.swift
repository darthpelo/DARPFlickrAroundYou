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
import Alamofire

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
        
        DARPPhotosDownloadManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    func checkDistance(userLocation: CLLocationCoordinate2D) -> (Bool) {
        
        let lat = lastUserLocation?.latitude
        let lon = lastUserLocation?.longitude
        
        if (lat == nil) || (lon == nil) {
            return true
        }
        
        let currentLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let lastLoc = CLLocation(latitude: lat!, longitude: lon!)
        
        if lastLoc.distanceFromLocation(currentLoc) > 50.0 {
            return true
        }
        return false
    }
    
    func updatePhotos(coordinate: CLLocationCoordinate2D) {
        let result = DownloadManager.downloadPhotos(coordinate, radius: 5)
        
        result.responseJSON { (request, response, JSON, error) -> Void in
            if error != nil {
                println("\(error?.debugDescription)")
            } else {
                println(JSON)
            }
        }
    }

    // MARK: - MKMapView delegate
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        var location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if checkDistance(location) == true {
            lastUserLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
            updatePhotos(lastUserLocation!)
            
            var region: MKCoordinateRegion
            
            var span = MKCoordinateSpanMake(0.002, 0.002)
            
            region = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
        }
    }

}

