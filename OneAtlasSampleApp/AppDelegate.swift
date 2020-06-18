//
//  AppDelegate.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 01/09/19.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas
import Mapbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var _backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(_backgroundTask)
        _backgroundTask = .invalid
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // startup wih SplashVC
        window = UIWindow(frame: UIScreen.main.bounds)
        let nc = UINavigationController(rootViewController: SplashVC.fromXib())
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        
        return true
    }
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        _backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // https://github.com/AFNetworking/AFNetworking/issues/4279#issuecomment-508363780
        URLSession.shared.flush {
            URLSession.shared.invalidateAndCancel()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate: AuthServiceDelegate {
    func onAuthTokenRefreshed(token: String) {
        return MGLNetworkConfiguration.sharedManager.sessionConfiguration.httpAdditionalHeaders = ["Authorization": token]
    }
}
