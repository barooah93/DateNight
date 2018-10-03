//
//  Extensions.swift
//  DateNight
//
//  Created by Brandon Barooah on 10/2/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

typealias SuccessBlock<T> = ((T)->Void)?
typealias FailureBlock = ((Error?)->Void)?

extension UIViewController {
    
    // Shows a loading indicator with optional title
    func presentLoadingOverlay(title: String = "") {
        DispatchQueue.main.async {
            
            let loadingOverlay = UIView(frame: self.view.frame)
            loadingOverlay.tag = Constants.loadingOverlayTag
            loadingOverlay.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            
            if(!title.isEmpty){
                let loadingTextLabel = UILabel(frame: CGRect(x: loadingOverlay.center.x-(loadingOverlay.frame.width/2),
                                                              y: loadingOverlay.center.y,
                                                              width: loadingOverlay.frame.width,
                                                              height: 20))
                loadingTextLabel.text = title
                loadingTextLabel.textAlignment = .center
                loadingTextLabel.textColor = UIColor.white
                loadingTextLabel.center.x = loadingOverlay.center.x
                loadingTextLabel.center.y = loadingOverlay.center.y
                loadingOverlay.addSubview(loadingTextLabel)
            }
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.center = loadingOverlay.center
            activityIndicator.frame.origin.y += 20
            activityIndicator.startAnimating()
            loadingOverlay.addSubview(activityIndicator)
            
            self.view.addSubview(loadingOverlay)
            
        }
    }
    
    // Hides any views with the loading overlay tag
    func hideLoadingOverlay() {
        self.view.subviews.forEach { view in
            if view.tag == Constants.loadingOverlayTag {
                DispatchQueue.main.async {
                    view.removeFromSuperview()
                }
            }
        }
        
    }
}
