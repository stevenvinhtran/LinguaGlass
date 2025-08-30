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
            print("Korean tokenizer has not been implemented yet. Using Japanese tokenizer as placeholder.")
            return try JapaneseTokenizer() // TODO: Replace with KoreanTokenizer()

        case .vietnamese:
            print("Vietnamese tokenizer has not been implemented yet. Using Japanese tokenizer as placeholder.")
            return try JapaneseTokenizer() // TODO: Replace with VietnameseTokenizer()
        }
    }

    static func makeWordButtons(
        from text: String,
        settings: AppSettings,
        selectedTokenID: Binding<UUID?>
    ) async throws -> [AnyView] {
        let tokenizer = try makeTokenizer(using: settings)
        let tokens = try await tokenizer.tokenize(text: text)

        return tokens.map { token in
            AnyView(
                WordButton(
                    token: token,
                    isSelected: selectedTokenID.wrappedValue == token.id
                ) {
                    selectedTokenID.wrappedValue = token.id
                }
            )
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
