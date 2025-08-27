//
//  SettingsModels.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

enum Language: String, CaseIterable, Identifiable, Codable {
    case japaneseVertical = "Japanese (Vertical)"
    case japaneseHorizontal = "Japanese (Horizontal)"
    case korean = "Korean"
    case vietnamese = "Vietnamese"
    
    var id: String { rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var id: String { rawValue }
}

struct AppSettings: Codable {
    var selectedLanguage: Language = .japaneseVertical
    var appTheme: AppTheme = .system
}
