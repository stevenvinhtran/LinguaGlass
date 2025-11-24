//
//  TokenizerHandler.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import SwiftUI
import NaturalLanguage

struct TokenizerHandler {
    static func makeTokenizer(using settings: AppSettings) throws -> TokenizerService {
        switch settings.selectedLanguage {
        case .japaneseVertical, .japaneseHorizontal:
            return try JapaneseTokenizer()
            
        case .korean:
            return KoreanTokenizer()
            
        case .vietnamese:
            return try VietnameseTokenizer()
            
        case .spanish, .french, .portuguese, .italian, .romanian:
            return LatinLanguageTokenizer(language: settings.selectedLanguage)
            
        case .chineseSimplifiedHorizontal, .chineseTraditionalHorizontal, .chineseSimplifiedVertical, .chineseTraditionalVertical:
            return ChineseTokenizer(language: settings.selectedLanguage)
        }
    }
    
    static func tokenize(
        _ text: String,
        headerViewModel: HeaderViewModel,
        settings: AppSettings
    ) async throws -> [Token] {
        let tokenizer = try makeTokenizer(using: settings)
        let tokens = try await tokenizer.tokenize(text: text.cleaned(for: settings.selectedLanguage))
        headerViewModel.isProcessing = false
        return tokens
    }
}
