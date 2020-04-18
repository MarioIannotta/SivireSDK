//
//  AppDelegate.swift
//  SivireDemo
//
//  Created by Mario on 17/04/2020.
//  Copyright © 2020 Mario Iannotta. All rights reserved.
//

import UIKit
import SivireSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SivireSDK.configure(port: "3000")
        return true
    }

}
