//
//  SettingsViewModel.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    private let settingsKey = "AppSettings"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved settings or use defaults
        if let savedSettings = UserDefaults.standard.data(forKey: settingsKey),
           let decodedSettings = try? JSONDecoder().decode(AppSettings.self, from: savedSettings) {
            self.settings = decodedSettings
        } else {
            self.settings = AppSettings()
        }
        
        applyTheme()
        
        $settings
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] newSettings in
                self?.saveSettings(newSettings)
            }
            .store(in: &cancellables)
    }
    
    public func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func applyTheme() {
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let windows = windowScene?.windows
            
            switch self.settings.appTheme {
            case .light:
                windows?.first?.overrideUserInterfaceStyle = .light
            case .dark:
                windows?.first?.overrideUserInterfaceStyle = .dark
            case .system:
                windows?.first?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    func getColorScheme() -> ColorScheme? {
        switch settings.appTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    func resetToDefaults() {
        settings = AppSettings()
        applyTheme()
    }
}
