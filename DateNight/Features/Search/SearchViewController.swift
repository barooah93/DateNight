//
//  HomeViewController.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/22/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    var locationUtilities : LocationUtilities?
    
    var userLocation : CLLocation?
    var mapRegion: MKCoordinateRegion?
    var isRegionChanged = false
    var isInitialLoad = true
    
    var mapView : MKMapView?
    var mapDelegate: SearchMapDelegate?
    
    var searchTableSource : SearchPlacesTableSource!
    var searchCompleter: MKLocalSearchCompleter!
    
    var managedContext: NSManagedObjectContext?
    
    var savedPlaces : [Place]?
    var places = [Place]()
    
    var defaultRadius : Int = 5 // Miles
    var defaultRadiusMeters : Double = 0.0 // Will get calculated in ViewDidLoad
    var milesToMetersMultiplier : Double = 1609.34
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location services
        locationUtilities = LocationUtilities(controller: self, delegate: self)

        // Set up search bar and completer
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.filterType = MKSearchCompletionFilterType.locationsAndQueries
        
        // Set up table view and source
        searchTableSource = SearchPlacesTableSource()
        searchTableSource.rowSelectedProtocol = self
        searchTableView.dataSource = searchTableSource
        searchTableView.delegate = searchTableSource
        searchTableView.isHidden = true
        
        // Set up map view
        self.mapView = MKMapView(frame: mapContainerView.frame)
        self.mapView?.showsCompass = true
        self.mapView?.mapType = .standard
        self.mapView?.showsPointsOfInterest = false
        self.mapView?.delegate = self
        self.mapView?.showsUserLocation = true
        self.view.insertSubview(mapView!, aboveSubview: mapContainerView)
        self.view.bringSubview(toFront: searchTableView)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Whenever we come back to the screen, get refreshed location if user did not manipulate region
        if !self.isRegionChanged {
            locationUtilities?.getUpdatedLocation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Size the map after views are layed out
        self.mapView?.frame = mapContainerView.frame
    }
    
    // Makes an mklocalsearchrequest for nearby restaurants
    func loadNearbyPlaces(region: MKCoordinateRegion) {
        
        // Make an mk search request with given region
        let request = MKLocalSearchRequest()
        request.region = region
        request.naturalLanguageQuery = "restuarant"
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (response, err) in
            if let _ = err {
                IOSUtilities.presentGenericAlertWithOK(self, title: "Error", message: "There was an issue finding eateries here")
                return
            }
            
            guard
                let searchResponse = response,
                let context = self.managedContext else {
                    print("Either no response from mklocalsearch or no managed context")
                    return
            }
            
            // Loop through items and add annotations
            for item in searchResponse.mapItems {
                let place = Place(context: context)
                place.latitude = item.placemark.coordinate.latitude
                place.longitude = item.placemark.coordinate.longitude
                place.name = item.placemark.name ?? ""
                place.address = "\(item.placemark.subThoroughfare ?? "") \(item.placemark.thoroughfare ?? "") \(item.placemark.locality ?? "")"
                self.places.append(place)
            }
            
        }
    }
    
    func clearTable(){
        // Hide table, clear results
        searchTableView.isHidden = true
        searchTableSource.titlesList = []
        searchTableSource.subtitlesList = []
        searchTableView.reloadData()
    }

}

// Core Location delegate
extension SearchViewController: LocationDelegate {
    
    func didReceiveLocation(location : CLLocation){
        
        // Zoom map to user's location if they have not manipulated the map yet
        self.userLocation = location
        self.mapRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        self.mapView?.setRegion(self.mapRegion!, animated: true)
        self.loadNearbyPlaces(region: self.mapRegion!)
    }
    
    func failedToReceiveLocation(err : Error){
        print("FAILED: \(err.localizedDescription)")
    }
}

// Search bar completer delegate
extension SearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        var titles = [String]()
        var subtitles = [String]()
        completer.results.forEach{ result in
            titles.append(result.title)
            subtitles.append(result.subtitle)
        }
        searchTableSource.titlesList = titles
        searchTableSource.subtitlesList = subtitles
        searchTableView.reloadData()
    }
    
}

// Search bar delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.clearTable()
        }else{
            // Perform completer query
            searchCompleter.queryFragment = searchText
            searchTableView.isHidden = false
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.clearTable()
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.clearTable()
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

// Search table row selected protocol
extension SearchViewController: PlacesTableRowSelectedProtocol {
    func didSelectRow(title: String?, subtitle: String?) {
        // TODO:
    }
}

// Map delegate to handle map events
extension SearchViewController: MKMapViewDelegate {
    
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Load nearby restaurants
        if self.isInitialLoad {
            self.isInitialLoad = false
        } else {
            self.isRegionChanged = true
        }
        
        self.loadNearbyPlaces(region: mapView.region)
    }
/*
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
 */
}

