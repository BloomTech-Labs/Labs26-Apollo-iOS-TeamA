//
//  AppDelegate.swift
//  LabsScaffolding
//
//  Created by Spencer Curtis on 6/17/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import OktaAuth
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(false, forKey: .notificationsVCdidLoad)

        let labelAppearance = UILabel.appearance()
        labelAppearance.font = UIFont(name: "Apple Symbols", size: 26)
        
        let titleAppearance = UINavigationBar.appearance()
        titleAppearance.titleTextAttributes = [.font : UIFont(name: "AppleSDGothicNeo-Bold", size: 25)!]
        titleAppearance.largeTitleTextAttributes = [.font : UIFont(name: "AppleSDGothicNeo-Bold", size: 41)!]
        
        let tabBarAppearance = UITabBarItem.appearance()
        tabBarAppearance.setTitleTextAttributes([.font : UIFont(name: "Apple Symbols", size: 16)!], for: .normal)
        
        UIButton.appearance().titleLabel?.font = UIFont(name: "Apple Symbols", size: 26) // not working

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
