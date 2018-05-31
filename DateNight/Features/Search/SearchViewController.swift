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
    
    var mapView : MKMapView?
    var mapDelegate: SearchMapDelegate?
    
    var searchTableSource : SearchPlacesTableSource!
    var searchCompleter: MKLocalSearchCompleter!
    
    var managedContext: NSManagedObjectContext?
    
    var savedPlaces : [Place]?
    
    var defaultRadius : Int = 5 // Miles
    var defaultRadiusMeters : Double = 0.0 // Will get calculated in ViewDidLoad
    var milesToMetersMultiplier : Double = 1609.34
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location services
        locationUtilities = LocationUtilities(controller: self, delegate: self)

        // Set up search bar and completer
        searchBar.delegate = self
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
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Whenever we come back to the screen, get refreshed location
        locationUtilities!.getUpdatedLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Size the map only after views are layed out
        if(mapView == nil){
            mapView = MKMapView(frame: mapContainerView.frame)
            mapView!.showsCompass = true
            mapView!.mapType = .standard
            mapDelegate = SearchMapDelegate()
            mapDelegate?.placesMapProtocol = self
            mapView!.delegate = mapDelegate
            mapView!.showsUserLocation = true
            self.view.insertSubview(mapView!, aboveSubview: mapContainerView)
            self.view.bringSubview(toFront: searchTableView)
            
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
        self.userLocation = location
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        self.mapView?.setRegion(region, animated: true)
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
    func didSelectRow(title: String, subtitle: String?) {
        // TODO
    }
}

// Map protocol to handle map events
extension SearchViewController: PlacesMapProtocol {
    func calloutWasSelected(coordinate: CLLocationCoordinate2D) {
        // TODO
    }
}

