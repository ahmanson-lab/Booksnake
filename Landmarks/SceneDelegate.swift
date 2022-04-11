//
//  SceneDelegate.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/21/20.
//  Copyright © 2020 University of Southern California. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
			//give all instances of UITableView a clear background color
			UITableView.appearance().backgroundColor = .clear
			
            let window = UIWindow(windowScene: windowScene)

            // Check if onboardingView is seen
            if UserDefaults.standard.bool(forKey: "isOnboardingShowed") == false {
                let rootViewController = UIHostingController(rootView: OnboardingView())
                window.rootViewController = rootViewController
            } else {
                // Get persistentContainer
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let rootViewController = UIHostingController(rootView: AssetRow().environment(\.managedObjectContext, context))
                window.rootViewController = rootViewController
            }

            // Set view for SwiftUI
            self.window = window
            window.screen.brightness = 1.0
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

