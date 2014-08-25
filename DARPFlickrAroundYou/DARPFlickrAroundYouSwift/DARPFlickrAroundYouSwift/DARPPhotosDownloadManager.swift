//
//  DARPPhotosDownloadManager.swift
//  DARPFlickrAroundYouSwift
//
//  Created by Alessio Roberto on 25/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

import Foundation
import CoreLocation

//private let _SingletonASharedInstance = DARPPhotosDownloadManager()

// Extending NSObject is not necessary. Doing it to use XCTest macros.

class DARPPhotosDownloadManager : NSObject {
    
    class func downloadPhotos(coordinate: CLLocationCoordinate2D, radius: Int) -> (photos: [Int], NSError?){
        return ([1,2,3,4], nil)
    }
    
}
