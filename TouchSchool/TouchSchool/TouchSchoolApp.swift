//
//  TouchSchoolApp.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture
import Firebase
import GoogleMobileAds

import SwiftUI

@main
struct TouchSchoolApp: App {
    
    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    static let store = Store(initialState: MainFeature.State()) {
        MainFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: TouchSchoolApp.store
            )
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
}
