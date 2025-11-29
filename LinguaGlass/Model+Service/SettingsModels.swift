//
//  SettingsModels.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

enum TargetLanguage: String, CaseIterable, Identifiable, Codable {
    case japaneseVertical
    case japaneseHorizontal
    case korean
    case vietnamese
    case spanish
    case french
    case portuguese
    case chineseSimplifiedVertical
    case chineseSimplifiedHorizontal
    case chineseTraditionalVertical
    case chineseTraditionalHorizontal
    case italian
    case romanian
    case english
    case other
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .japaneseVertical: return String(localized: "Japanese (Vertical)")
        case .japaneseHorizontal: return String(localized: "Japanese (Horizontal)")
        case .korean: return String(localized: "Korean")
        case .vietnamese: return String(localized: "Vietnamese")
        case .spanish: return String(localized: "Spanish")
        case .french: return String(localized: "French")
        case .portuguese: return String(localized: "Portuguese")
        case .chineseSimplifiedVertical: return String(localized: "Chinese (Simplified, Vertical)")
        case .chineseSimplifiedHorizontal: return String(localized: "Chinese (Simplified, Horizontal)")
        case .chineseTraditionalVertical: return String(localized: "Chinese (Traditional, Vertical)")
        case .chineseTraditionalHorizontal: return String(localized: "Chinese (Traditional, Horizontal)")
        case .italian: return String(localized: "Italian")
        case .romanian: return String(localized: "Romanian")
        case .english: return String(localized: "English")
        case .other: return String(localized: "Other")
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "English"
    case japanese = "日本語"
    case korean = "한국어"
    case vietnamese = "Tiếng Việt"
    case spanish = "Español"
    case french = "Français"
    case portuguese = "Português"
    case chineseSimplified = "中文(简体)"
    case chineseTraditional = "中文(繁體)"
    case italian = "Italiano"
    case romanian = "Română"
    
    var id: String { rawValue }
    
    var localeIdentifier: String {
        switch self {
        case .english: return "en"
        case .japanese: return "ja"
        case .korean: return "ko"
        case .vietnamese: return "vi"
        case .spanish: return "es"
        case .french: return "fr"
        case .portuguese: return "pt"
        case .chineseSimplified: return "zh-Hans"
        case .chineseTraditional: return "zh-Hant"
        case .italian: return "it"
        case .romanian: return "ro"
        }
    }
    
    var displayName: String { String(localized: .init(rawValue))}
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case system
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        case .system: return String(localized: "System")
        }
    }
}

enum NewTabBehavior: String, CaseIterable, Identifiable, Codable {
    case ask
    case alwaysOpen
    case neverOpen
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .ask: return String(localized: "Ask before opening")
        case .alwaysOpen: return String(localized: "Always open")
        case .neverOpen: return String(localized: "Never open")
        }
    }
}

struct AppSettings: Codable {
    var targetLanguage: TargetLanguage = .japaneseVertical
    var appLanguage: AppLanguage = .english
    var appTheme: AppTheme = .system
    var newTabBehavior: NewTabBehavior = .ask
}

