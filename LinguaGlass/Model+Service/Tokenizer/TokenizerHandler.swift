//
//  TokenizerHandler.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import SwiftUI

struct TokenizerHandler {
    static func makeTokenizer(using settings: AppSettings) throws -> TokenizerService {
        switch settings.selectedLanguage {
        case .japaneseVertical, .japaneseHorizontal:
            return try JapaneseTokenizer()

        case .korean:
            return KoreanTokenizer()

        case .vietnamese:
            print("Vietnamese tokenizer has not been implemented yet. Using Korean tokenizer as placeholder.")
            return KoreanTokenizer() // TODO: Replace with VietnameseTokenizer()
        }
    }

    static func tokenize(
        _ text: String,
        settings: AppSettings
    ) async throws -> [Token] {
        let tokenizer = try makeTokenizer(using: settings)
        return try await tokenizer.tokenize(text: text)
    }
}
