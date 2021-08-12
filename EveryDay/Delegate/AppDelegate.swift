//
//  AppDelegate.swift
//  EveryDay
//
//  Created by "pl" on 2020/10/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        let vc = ViewController()
        let nav = UINavigationController.init(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }
}

