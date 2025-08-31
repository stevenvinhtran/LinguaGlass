//
//  TokenFooterViewModel.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import SwiftUI
import UIKit

@MainActor
final class TokenFooterViewModel: ObservableObject {
    @Published var tokens: [Token] = []
    @Published var isEditing = false
    @Published var editText = ""
    @Published var selectedTokenID: UUID?
    @Published var showDictionary = false
    @Published var selectedToken: Token?
    
    func beginEditing() {
        editText = tokens.map { $0.text }.joined(separator: "  ")
        isEditing = true
    }

    func commitEditing(settingsViewModel: SettingsViewModel) {
        Task { await tokenize(from: editText, settingsViewModel: settingsViewModel) }
        isEditing = false
    }

    func pasteFromClipboard(settingsViewModel: SettingsViewModel) {
        if let text = UIPasteboard.general.string {
            Task { await tokenize(from: text, settingsViewModel: settingsViewModel) }
            isEditing = false
        }
    }
    
    func searchAllTokens(settingsViewModel: SettingsViewModel) {
        guard !tokens.isEmpty else { return }
        
        let searchText: String
        switch settingsViewModel.settings.selectedLanguage {
        case .japaneseVertical, .japaneseHorizontal:
            // Japanese concatenates all tokens without spaces
            searchText = tokens.map { $0.text }.joined()
        case .korean, .vietnamese:
            // Korean and Vietnamese join with spaces
            searchText = tokens.map { $0.text }.joined(separator: " ")
        }
        
        // Show dictionary with the combined search text
        let combinedToken = Token(
            text: searchText,
            dictionaryForm: nil,
            reading: nil,
            furigana: nil
        )
        showDictionary(for: combinedToken)
    }
    
    func showDictionary(for token: Token) {
        selectedToken = token
        showDictionary = true
    }
    
    func hideDictionary() {
        showDictionary = false
        selectedToken = nil
    }

    func tokenize(from text: String, settingsViewModel: SettingsViewModel) async {
        do {
            let newTokens = try await TokenizerHandler.tokenize(text, settings: settingsViewModel.settings)
            tokens = newTokens
        } catch {
            print("Tokenization failed: \(error)")
        }
    }
}
