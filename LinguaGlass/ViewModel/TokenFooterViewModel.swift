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

    func tokenize(from text: String, settingsViewModel: SettingsViewModel) async {
        do {
            let newTokens = try await TokenizerHandler.tokenize(text, settings: settingsViewModel.settings)
            tokens = newTokens
        } catch {
            print("Tokenization failed: \(error)")
        }
    }
}
