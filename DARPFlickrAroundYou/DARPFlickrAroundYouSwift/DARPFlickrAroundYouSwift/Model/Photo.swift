//
//  Photo.swift
//  DARPFlickrAroundYouSwift
//
//  Created by Alessio Roberto on 28/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var photoid: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var title: String
    @NSManaged var thumbURL: String

}
