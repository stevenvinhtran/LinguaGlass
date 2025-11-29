//
//  EnglishTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/29/25.
//

import Foundation
import NaturalLanguage

struct OtherTokenizer: TokenizerService {
    func tokenize(text: String) async throws -> [Token] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(.undetermined)
        tokenizer.string = text
        var tokens: [Token] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let tokenText = String(text[tokenRange])
            tokens.append(Token(text: tokenText))
            return true
        }
        return tokens
    }
}
