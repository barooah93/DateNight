//
//  LocationUtilities.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/30/18.
//  Copyright © 2018 personal. All rights reserved.
//


import UIKit
import CoreLocation

class LocationUtilities: NSObject, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager?
    var locationDelegate : LocationDelegate?
    var geocoder : CLGeocoder?
    weak var controller : UIViewController?
    
    var authorizationDetermined = false
    var locationSent = false
    
    init(controller: UIViewController, delegate : LocationDelegate) {
        super.init()
        self.controller = controller
        self.locationDelegate = delegate
        self.locationManager = CLLocationManager()
        self.geocoder = CLGeocoder()
        
        if(CLLocationManager.authorizationStatus() != .notDetermined){
            authorizationDetermined = true
        }
        self.locationManager!.delegate = self
    }
    
    func getUpdatedLocation(){
        
        locationSent = false
        
        if(authorizationDetermined){
            locationManager!.startUpdatingLocation()
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check if user has just clicked on allow or decline on authorization popup
        if(!authorizationDetermined && CLLocationManager.authorizationStatus() != .notDetermined){
            authorizationDetermined = true
            if(CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
                locationManager!.startUpdatingLocation()
            } else if(CLLocationManager.authorizationStatus() == .denied){
                // Prompt user to go to settings and change it
                promptSettingsAlert()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(locationManager!.location != nil){
            locationManager!.stopUpdatingLocation()
            if(!locationSent){
                locationDelegate?.didReceiveLocation(location: locationManager!.location!)
                locationSent = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if(CLLocationManager.authorizationStatus() == .denied){
            promptSettingsAlert()
        } else {
            locationDelegate?.failedToReceiveLocation(err: error)
        }
    }
    
    func promptSettingsAlert(){
        let alertController = UIAlertController(title: "Whoa There!", message: "In order for us to find nearby restaurants, please open this app's settings and turn location on.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler:
            {(action: UIAlertAction) in
                IOSUtilities.openSettings()
                self.locationSent = true
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.controller?.present(alertController, animated: true, completion: nil)
    }
    
    
    func reverseGeocodeLocationToAddress(_ location:CLLocation, completion:((String?)->(Void))?){
        var address:String? = nil
        geocoder?.reverseGeocodeLocation(location, completionHandler: { (placemarks, err) in
            if let placemarks = placemarks, placemarks.count > 0, err == nil {
                
                let name = placemarks[0].addressDictionary?["Name"] as? String ?? ""
                let street = placemarks[0].addressDictionary?["Street"] as? String ?? ""
                let city = placemarks[0].addressDictionary?["City"] as? String ?? ""
                let state = placemarks[0].addressDictionary?["State"] as? String ?? ""
                address = "\(name), \(street) \(city), \(state)"
                
            }
            if completion != nil {
                completion!(address)
            }
        })
    }
    
    
}

protocol LocationDelegate {
    func didReceiveLocation(location : CLLocation)
    func failedToReceiveLocation(err : Error)
}
