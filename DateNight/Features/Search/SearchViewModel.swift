//
//  SearchViewModel.swift
//  DateNight
//
//  Created by Brandon Barooah on 9/11/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class SearchViewModel: NSObject {
    
    // Initialize the core data stack managed context
    var managedContext = CoreDataStack.init(modelName: "Places").managedContext

    var savedPlaces : [Place]?
    var places: [Place] = []
    
    // Takes in a region and sets the places with found nearby restaurants
    func loadNearbyPlaces(with map: MKMapView, success: (() -> Void)?, failure: FailureBlock) {
        
        // Clear existing annotations
        places = []
        map.removeAnnotations(map.annotations)
        
        // Make an mk search request with given map
        let request = MKLocalSearchRequest()
        request.region = map.region
        request.naturalLanguageQuery = "restuarant"
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (response, error) in
            if let err = error {
                failure?(err)
                return
            }
            
            guard
                let searchResponse = response else {
                    print("No response from mklocalsearch")
                    return
            }
            
            // Loop through items and add annotations
            for item in searchResponse.mapItems {
                let place = Place(context: self.managedContext)
                place.latitude = item.placemark.coordinate.latitude
                place.longitude = item.placemark.coordinate.longitude
                place.name = item.placemark.name ?? ""
                place.address = "\(item.placemark.subThoroughfare ?? "") \(item.placemark.thoroughfare ?? "") \(item.placemark.locality ?? "")"
                self.places.append(place)
                
                // Add annotation
                let annotation = CustomAnnotation(title: place.name, subtitle: place.address, coordinate: item.placemark.coordinate)
                map.addAnnotation(annotation)
                
            }
            success?()
        }
    }
}
