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

class DownloadManager : NSObject {
    // MARK: - Public
    public func downloadPhotos(coordinate: CLLocationCoordinate2D, radius: Int) -> Request{
        let result = Manager.sharedInstance.searchPhotosByCoordinate(coordinate, radius: radius)
        
        return result
    }
    
    // MARK: - Private
    func photosData(list: [Dictionary]) {
        
    }
}
