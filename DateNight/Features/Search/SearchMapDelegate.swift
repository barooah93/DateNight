//
//  SearchMapDelegate.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/30/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import MapKit

protocol PlacesMapProtocol {
    func calloutWasSelected(coordinate : CLLocationCoordinate2D)
}

class SearchMapDelegate: NSObject, MKMapViewDelegate {

    var placesMapProtocol : PlacesMapProtocol?
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if(annotation is MKUserLocation){
            return nil
        }
        
        let pinId = "customPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId)
        
        if(annotationView == nil){
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            annotationView?.canShowCallout = true
//            annotationView?.image = UIImage(named: "Map_Pin")
//            let garbage = UIImageView(image: (UIImage(named: "Edit_Icon")))
//            garbage.isUserInteractionEnabled = true
//            annotationView?.rightCalloutAccessoryView = garbage
            
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
/**
    // Add gesture recognizer
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.calloutSelected(_ :)))
        view.addGestureRecognizer(tapGesture)
    }
    // Remove all gesture recognizers
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.gestureRecognizers?.forEach({gesture in
            view.removeGestureRecognizer(gesture)
        })
    }
    func calloutSelected(_ sender: UITapGestureRecognizer){
        if let view = sender.view as? MKAnnotationView {
            if let annotation = view.annotation as? CustomAnnotation {
                placesMapProtocol?.calloutWasSelected(coordinate: annotation.coordinate)
            }
        }
    }
**/
}
