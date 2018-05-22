//
//  AppDelegate.swift
//  DateNight
//
//  Created by Brandon Barooah on 5/22/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack = CoreDataStack(modelName: "Places")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let viewController = tabController.viewControllers?.first as? HomeViewController else {
                return true
        }
        
        viewController.managedContext = coreDataStack.managedContext
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        coreDataStack.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }


}

