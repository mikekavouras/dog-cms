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

        let tabController = UITabBarController()
        tabController.viewControllers = [dogController, creaturesController]
        window = UIWindow()

        window?.rootViewController = tabController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
    
    lazy private var dogController: UINavigationController = {
        let controller = ViewController(DogAPI.self, title: "Dog") { viewController in
            viewController.tabBarItem = UITabBarItem(title: "Dog", image: UIImage(named: "dog")!, selectedImage: UIImage(named: "dog")!)
        }
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }()
    
    lazy private var creaturesController: UINavigationController = {
        let controller = ViewController(CreaturesAPI.self, title: "Creatures") { viewController in
            viewController.tabBarItem = UITabBarItem(title: "Creatures", image: UIImage(named: "creatures")!, selectedImage: UIImage(named: "creatures")!)
        }
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }()
}

