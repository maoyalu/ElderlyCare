//
//  LocationAnnotation.swift
//  ElderlyCare
//
//  Created by Lu Yang on 3/11/19.
//  Copyright © 2019 Lu Yang. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(newTitle: String, lat: Double, long: Double){
        title = newTitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

}
