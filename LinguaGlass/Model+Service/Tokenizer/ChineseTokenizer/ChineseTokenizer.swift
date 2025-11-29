//
//  ChineseTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/24/25.
//

import Foundation
import NaturalLanguage
import WWJavaScriptContext
import WWJavaScriptContext_Pinyin

struct ChineseTokenizer: TokenizerService {
    let language: TargetLanguage
    
    func tokenize(text: String) async throws -> [Token] {
        let nlLanguage: NLLanguage
        switch language {
        case .chineseSimplifiedHorizontal, .chineseSimplifiedVertical:
            nlLanguage = .simplifiedChinese
        case .chineseTraditionalHorizontal, .chineseTraditionalVertical:
            nlLanguage = .traditionalChinese
        default:
            nlLanguage = .undetermined
        }
        
        let nlTokenizer = NLTokenizer(unit: .word)
        nlTokenizer.string = text
        nlTokenizer.setLanguage(nlLanguage)
        
        var tokens: [Token] = []
        nlTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let word = String(text[tokenRange])
            let ruby = ChineseUtils.getPinyin(text: word)
            tokens.append(Token(text: word, rubyText: ruby.isEmpty ? nil : ruby))
            return true
        }
        
        return tokens
    }
}

