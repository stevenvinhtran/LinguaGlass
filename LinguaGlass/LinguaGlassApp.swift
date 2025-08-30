//
//  LinguaGlassApp.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

@main
struct LinguaGlassApp: App {
    var body: some Scene {
        WindowGroup {
            UIKitWrapper {
                MainView()
            }
            .ignoresSafeArea(.all)
        }
    }
}
