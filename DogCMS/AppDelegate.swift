//
//  AppDelegate.swift
//  DogCMS
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let navController = window?.rootViewController as? UINavigationController,
            let rootViewController = navController.viewControllers.first as? ViewController
        {
            rootViewController.fetchStickers()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) { }
}
