//
//  TutorialManager.swift
//  LinguaGlass
//
//  Created by Steven Tran on 9/1/25.
//

import Foundation

class TutorialManager {
    static let shared = TutorialManager()
    
    private let hasSeenTutorialKey = "hasSeenTutorial"
    
    var shouldShowTutorial: Bool {
        !UserDefaults.standard.bool(forKey: hasSeenTutorialKey)
    }
    
    func markTutorialAsSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenTutorialKey)
    }
    
    func resetTutorial() {
        UserDefaults.standard.set(false, forKey: hasSeenTutorialKey)
    }
}
