//
//  CubStartFinalApp.swift
//  CubStartFinal
//
//  Created by Jonathan Dinh on 11/22/23.
//

import SwiftUI
//import FirebaseCore
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//
//  func application(_ application: UIApplication,
//
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//
//    FirebaseApp.configure()
//
//    return true
//
//  }
//
//}
@main
struct CulinaryConnect: App {
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var userSession = UserSession()  // Create an instance of UserSession
    @StateObject var favoriteRecipes = FavoriteRecipes()

    var body: some Scene {
        WindowGroup {
            FeastLoginView()
                .environmentObject(userSession)  // Inject UserSession into FeastLoginView
                .environmentObject(favoriteRecipes)
        }
    }
}
