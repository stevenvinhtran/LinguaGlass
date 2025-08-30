//
//  JapaneseTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import Foundation
import Mecab_Swift
import IPADic

final class JapaneseTokenizer: TokenizerService {
    private let tokenizer: Mecab_Swift.Tokenizer

    init() throws {
        let dictionary = IPADic()
        self.tokenizer = try Mecab_Swift.Tokenizer(dictionary: dictionary)
    }

    func tokenize(text: String) async throws -> [Token] {
        let mecabTokens = tokenizer.tokenize(text: text, transliteration: .hiragana)

        return mecabTokens.map { mecabToken in
            let furigana = JapaneseUtils.getFurigana(
                text: mecabToken.base,
                reading: mecabToken.reading
            )

            return Token(
                text: mecabToken.base,
                dictionaryForm: mecabToken.dictionaryForm,
                reading: mecabToken.reading,
                furigana: furigana.isEmpty ? nil : furigana
            )
        }
    }
}

