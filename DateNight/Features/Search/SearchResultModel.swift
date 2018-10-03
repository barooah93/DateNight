//
//  SearchResultModel.swift
//  DateNight
//
//  Created by Brandon Barooah on 9/12/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

class SearchResultModel: NSObject {

    var title: String = ""
    var subtitle: String = ""
    
    init?(_ title: String, _ subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
