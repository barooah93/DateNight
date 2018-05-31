//
//  IOSUtilities.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/30/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

class IOSUtilities: NSObject {
    
    static func presentGenericAlertWithOK(_ controller: UIViewController, title: String, message: String){
        
        // Make sure view controller is still the one presented
        if(AppDelegate.topViewController() == controller){
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                controller.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    static func openSettings(){
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString){
            if(UIApplication.shared.canOpenURL(settingsURL)){
                UIApplication.shared.openURL(settingsURL)
            }
        }
    }

}
