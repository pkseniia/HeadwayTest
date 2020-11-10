//
//  AppDelegate.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 09.11.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            StartService.shared.start(in: window)
        }
        return true
    }
}

