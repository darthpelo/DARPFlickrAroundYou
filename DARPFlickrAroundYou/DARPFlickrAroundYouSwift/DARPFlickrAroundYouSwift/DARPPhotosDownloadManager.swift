//
//  DARPPhotosDownloadManager.swift
//  DARPFlickrAroundYouSwift
//
//  Created by Alessio Roberto on 25/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

//private let _SingletonASharedInstance = DARPPhotosDownloadManager()

// Extending NSObject is not necessary. Doing it to use XCTest macros.

public typealias Result = ([String], NSError?)

class DARPPhotosDownloadManager : NSObject {
    
    class func downloadPhotos(coordinate: CLLocationCoordinate2D, radius: Int) -> Request{
        let result = Manager.sharedInstance.searchPhotosByCoordinate(coordinate, radius: radius)
        
        return result
        /*
        var list: [String]
        var err: NSError?
        result.responseJSON { (request, response, JSON, error) -> Void in
        println(JSON)
        }
        */
    }
    
}
