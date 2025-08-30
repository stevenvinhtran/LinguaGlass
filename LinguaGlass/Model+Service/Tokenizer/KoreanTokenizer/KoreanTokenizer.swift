//
//  KoreanTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/30/25.
//

import Foundation
import NaturalLanguage

struct KoreanTokenizer: TokenizerService {
    func tokenize(text: String) async throws -> [Token] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        tokenizer.setLanguage(.korean)

        var tokens: [Token] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let word = String(text[range])
            
            if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tokens.append(Token(text: word))
            }
            return true
        }
        return tokens
    }
}

