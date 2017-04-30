//
//  AppDelegate.swift
//  AirportLookUp
//
//  Created by Grover Chen on 4/15/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import Alamofire

let centerLat = 39.9526
let centerLon = -75.1652

extension Notification.Name {
    static let userDidChange = Notification.Name("userDidChange")
    static let AirportInfoDidChange = Notification.Name("AirportInfoDidChange")
    static let pinDidChange = Notification.Name("pinDidChange")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()
    var center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
    
    
    var userLocation: CLLocation? {
        didSet{
            let notification = Notification(name: Notification.Name.userDidChange)
            NotificationCenter.default.post(notification)
        }
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.startLocate()

        return true
    }
    
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    func startLocate() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100.0
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations: \(locations)")
        userLocation = locations.last
    }
    
}

