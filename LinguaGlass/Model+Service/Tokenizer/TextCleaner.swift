//
//  TextCleaner.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/31/25.
//

import Foundation

extension String {
    func cleaned(for language: Language) -> String {
        // Trim + lowercase
        var result = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        // Replace linebreaks with double spaces
        result = result.replacingOccurrences(of: "\n", with: "  ")
        
        var notAllowed = CharacterSet.decimalDigits
        
        // Configure notAllowed based on language
        switch language {
        case .japaneseHorizontal, .japaneseVertical, .korean, .chineseSimplifiedHorizontal, .chineseSimplifiedVertical, .chineseTraditionalHorizontal, .chineseTraditionalVertical:
            // strip ASCII letters + digits + punctuation
            let asciiLetters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            notAllowed.formUnion(asciiLetters)
            notAllowed.formUnion(CharacterSet(charactersIn:"-_/\\()|〔〕[]{}%:<>"))
            
        case .vietnamese:
            // strip digits + only a few symbols, keep Latin letters
            notAllowed.formUnion(CharacterSet(charactersIn:"-_/\\()|〔〕[]{}%:<>"))
            
        case .spanish, .french, .portuguese, .italian, .romanian:
            // For these languages, do not strip letters or punctuation beyond digits
            break
        }
        
        // Filter out forbidden scalars
        let filtered = result.unicodeScalars.filter { !notAllowed.contains($0) }
        result = String(String.UnicodeScalarView(filtered))
        
        // Split on any whitespace, drop empties, re-join with exactly one space or none based on language
        switch language {
        case .japaneseVertical, .japaneseHorizontal, .chineseSimplifiedHorizontal, .chineseSimplifiedVertical, .chineseTraditionalHorizontal, .chineseTraditionalVertical:
            let parts = result.split(whereSeparator: { $0.isWhitespace })
            result = parts.joined(separator: "")
            
        case .korean, .vietnamese, .spanish, .french, .portuguese, .italian, .romanian:
            let parts = result.split(whereSeparator: { $0.isWhitespace })
            result = parts.joined(separator: " ")
        }
        
        return result
    }
}
