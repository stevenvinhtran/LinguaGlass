//
//  SettingsModels.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation
import SwiftUI

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
    var displayName: LocalizedStringKey {
        switch self {
        case .japaneseVertical: return  "Japanese (Vertical)"
        case .japaneseHorizontal: return  "Japanese (Horizontal)"
        case .korean: return  "Korean"
        case .vietnamese: return  "Vietnamese"
        case .spanish: return  "Spanish"
        case .french: return  "French"
        case .portuguese: return  "Portuguese"
        case .chineseSimplifiedVertical: return  "Chinese (Simplified, Vertical)"
        case .chineseSimplifiedHorizontal: return  "Chinese (Simplified, Horizontal)"
        case .chineseTraditionalVertical: return  "Chinese (Traditional, Vertical)"
        case .chineseTraditionalHorizontal: return  "Chinese (Traditional, Horizontal)"
        case .italian: return  "Italian"
        case .romanian: return  "Romanian"
        case .english: return  "English"
        case .other: return  "Other"
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
    
    var displayName: String { .init(rawValue)}
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case system
    
    var id: String { rawValue }
    var displayName: LocalizedStringKey {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

enum NewTabBehavior: String, CaseIterable, Identifiable, Codable {
    case ask
    case alwaysOpen
    case neverOpen
    
    var id: String { rawValue }
    var displayName: LocalizedStringKey {
        switch self {
        case .ask: return "Ask before opening"
        case .alwaysOpen: return "Always open"
        case .neverOpen: return "Never open"
        }
    }
}

struct AppSettings: Codable {
    var targetLanguage: TargetLanguage = .japaneseVertical
    var appLanguage: AppLanguage = .defaultForCurrentLocale()
    var appTheme: AppTheme = .system
    var newTabBehavior: NewTabBehavior = .ask
}


extension AppLanguage {
    static func defaultForCurrentLocale() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"

        if preferred.hasPrefix("ja") { return .japanese }
        if preferred.hasPrefix("ko") { return .korean }
        if preferred.hasPrefix("vi") { return .vietnamese }
        if preferred.hasPrefix("es") { return .spanish }
        if preferred.hasPrefix("fr") { return .french }
        if preferred.hasPrefix("pt") { return .portuguese }
        if preferred.hasPrefix("it") { return .italian }
        if preferred.hasPrefix("ro") { return .romanian }
        
        if preferred.hasPrefix("zh-Hans") || preferred.hasPrefix("zh-CN") || preferred.hasPrefix("zh-SG") {
            return .chineseSimplified
        }
        
        if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") || preferred.hasPrefix("zh-HK") {
            return .chineseTraditional
        }

        return .english
    }
}

