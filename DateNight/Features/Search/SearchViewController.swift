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
    
    // View model
    var searchViewModel = SearchViewModel()
    
    // Views
    var mapView : MKMapView?
    var mapDelegate: SearchMapDelegate?
    
    var searchTableSource : SearchPlacesTableSource?
    var searchCompleter: MKLocalSearchCompleter?
    
    // Properties
    var isRegionChanged = false
    var isInitialLoad = true
    
    var userLocation : CLLocation?
    var mapRegion: MKCoordinateRegion?

    var locationUtilities : LocationUtilities?
    
    var defaultRadius : Double = 0.5 // Miles
    var milesToMetersMultiplier : Double = 1609.34
    
    var defaultRadiusMeters : Double {
        get {
            return milesToMetersMultiplier * defaultRadius
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set up location services
        locationUtilities = LocationUtilities(controller: self, delegate: self)
        
        // Set up search bar and completer
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.filterType = MKSearchCompletionFilterType.locationsAndQueries
        
        // Set up table view and source
        searchTableSource = SearchPlacesTableSource()
        searchTableSource?.rowSelectedProtocol = self
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
    func loadNearbyPlaces() {
        guard let map = self.mapView else {
            IOSUtilities.presentGenericAlertWithOK(self, title: "Error", message: "Map was set to nil")
            return
        }
        
        self.presentLoadingOverlay(title: "Finding restaurants near you!")
        self.searchViewModel.loadNearbyPlaces(with: map, success: {[weak self] in
            self?.hideLoadingOverlay()
        }, failure: {[weak self] err in
            guard let wSelf = self else { return }
            if let err = err {
                print("\(err) \(err.localizedDescription)")
            }
            IOSUtilities.presentGenericAlertWithOK(wSelf, title: "Error", message: "There was an issue finding eateries here")
        })
    }
    
    func clearTable(){
        // Hide table, clear results
        searchTableView.isHidden = true
        searchTableSource?.titlesList = []
        searchTableSource?.subtitlesList = []
        searchTableView.reloadData()
    }

}

// Location Utilities delegate
extension SearchViewController: LocationDelegate {
    
    func didReceiveLocation(location : CLLocation){
        
        // Zoom map to user's location if they have not manipulated the map yet
        self.userLocation = location
        self.mapRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, defaultRadiusMeters, defaultRadiusMeters)
        self.mapView?.setRegion(self.mapRegion!, animated: true)
        self.loadNearbyPlaces()
    }
    
    func failedToReceiveLocation(err : Error){
        print("ERROR: \(err.localizedDescription)")
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
        searchTableSource?.titlesList = titles
        searchTableSource?.subtitlesList = subtitles
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
            searchCompleter?.queryFragment = searchText
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
        
        self.loadNearbyPlaces()
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

