//
//  MorfandoLocalApp.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI

@main
struct MorfandoLocalApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LaunchView() // FIRST SCREEN
        }
    }
}
