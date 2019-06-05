//
//  SearchPlacesTableSource.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/30/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import MapKit

protocol PlacesTableRowSelectedProtocol : class {
    func didSelectRow(result: MKLocalSearchCompletion)
}

class SearchPlacesTableSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var tableView: UITableView?
    var results: [MKLocalSearchCompletion]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    weak var rowSelectedProtocol : PlacesTableRowSelectedProtocol?
    
    init(tableView: UITableView, results: [MKLocalSearchCompletion] = []){
        self.tableView = tableView
        self.results = results
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "tableCell")
        }
        cell?.textLabel?.text = results?[indexPath.row].title
        cell?.detailTextLabel?.text = results?[indexPath.row].subtitle
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let result = results?[indexPath.row] else { return }
        rowSelectedProtocol?.didSelectRow(result: result)
    }
    
    
}
