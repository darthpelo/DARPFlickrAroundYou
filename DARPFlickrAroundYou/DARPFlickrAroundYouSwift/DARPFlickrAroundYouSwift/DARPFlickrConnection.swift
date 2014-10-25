//
//  DARPFlickrConnection.swift
//  DARPFlickrAroundYouSwift
//
//  Created by Alessio Roberto on 25/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

enum Flickr {
    case ServicesRest
}

struct FlickrKey {
    let key = "59826ab533525345d34306c1cbc70e93"
    let secret = "b67819fc7f9aaa9d"
}

protocol Path {
    var path : String { get }
}

extension Flickr : Path {
    var path: String {
        switch self {
        case .ServicesRest: return "/services/rest"
//        case .UserProfile(let name): return "/users/\(name)"
        }
    }
}

class Manager {
    class var sharedInstance: Manager {
    struct Singleton {
        static let instance = Manager()
        }
        
        return Singleton.instance
    }
    
    let flickr = FlickrKey()
    let flickrService = "https://api.flickr.com\(Flickr.ServicesRest)"
    
    func searchPhotosByCoordinate(cooridnate: CLLocationCoordinate2D, radius: Int) -> Request {
        return Alamofire.request(.GET, flickrService, parameters: ["method": "flickr.photos.search",
            "api_key": flickr.key, "accuracy": 11, "lat": cooridnate.latitude, "lon": cooridnate.longitude, "radius": radius, "format": "json",
            "nojsoncallback": 1])
    }
}