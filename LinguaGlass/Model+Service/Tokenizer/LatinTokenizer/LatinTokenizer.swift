//
//  LatinTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/24/25.
//

import Foundation
import NaturalLanguage

class LatinLanguageTokenizer: TokenizerService {
    let language: TargetLanguage
    let nlLanguage: NLLanguage
    
    init(language: TargetLanguage) {
        self.language = language
        switch language {
        case .spanish:
            nlLanguage = .spanish
        case .french:
            nlLanguage = .french
        case .portuguese:
            nlLanguage = .portuguese
        case .italian:
            nlLanguage = .italian
        case .romanian:
            nlLanguage = .romanian
        default:
            nlLanguage = .undetermined
        }
    }
    
    func tokenize(text: String) async throws -> [Token] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(nlLanguage)
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
