//
//  AppDelegate.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import Firebase

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
}
