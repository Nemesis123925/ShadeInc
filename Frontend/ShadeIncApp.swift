//
//  ShadeIncApp.swift
//  ShadeInc
//
//  Created by Randi Gjoni on 3/29/22.
//

import SwiftUI
import Firebase
@main
struct ShadeIncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)   var appDelegagte
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
