//
//  CustomAnnotation.swift
//  DateNight
//
//  Created by Brandon Barooah on 10/2/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var title : String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String?, subtitle:String?, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    override convenience init(){
        self.init(title: "",subtitle: "", coordinate: CLLocationCoordinate2D(latitude: 0,longitude: 0))
    }
}
