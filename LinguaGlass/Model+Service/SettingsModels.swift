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
    case spanish = "Spanish"
    case french = "French"
    case portuguese = "Portuguese"
    case chineseSimplifiedVertical = "Chinese (Simplified, Vertical)"
    case chineseSimplifiedHorizontal = "Chinese (Simplified, Horizontal)"
    case chineseTraditionalVertical = "Chinese (Traditional, Vertical)"
    case chineseTraditionalHorizontal = "Chinese (Traditional, Horizontal)"
    case italian = "Italian"
    case romanian = "Romanian"
    
    var id: String { rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var id: String { rawValue }
}

enum NewTabBehavior: String, CaseIterable, Identifiable, Codable {
    case ask = "Ask before opening"
    case alwaysOpen = "Always open"
    case neverOpen = "Never open"
    
    var id: String { rawValue }
}

struct AppSettings: Codable {
    var selectedLanguage: Language = .japaneseVertical
    var appTheme: AppTheme = .system
    var newTabBehavior: NewTabBehavior = .ask
}
