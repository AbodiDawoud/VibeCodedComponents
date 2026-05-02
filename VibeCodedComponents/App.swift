//
//  VibeCodedComponentsApp.swift
//  VibeCodedComponents
    

import SwiftUI

@main
struct VibeCodedComponentsApp: App {    
    @AppStorage(__AppearanceKey) var appAppearance: String?
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(root: ContentView.init)
                .preferredColorScheme(__colorScheme)
        }
    }
    
    var __colorScheme: ColorScheme? {
        guard let appAppearance else { return nil } // fallback to system
        if appAppearance.contains("light") { return .light }
        else { return .dark }
    }
}


public extension UIWindow {
     override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let appearance = UserDefaults.standard.value(forKey: __AppearanceKey) as? String
            let new_appearance = appearance == "light" ? "dark" : "light"
            UserDefaults.standard.set(new_appearance, forKey: __AppearanceKey)
        }
         
        super.motionEnded(motion, with: event)
     }
}

fileprivate let __AppearanceKey: String = "AppAppearance"
