//
//  Token.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import Foundation

struct Token: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let dictionaryForm: String?
    let reading: String?
    let furigana: [Furigana]?

    init(
        text: String,
        dictionaryForm: String? = nil,
        reading: String? = nil,
        furigana: [Furigana]? = nil
    ) {
        self.text = text
        self.dictionaryForm = dictionaryForm
        self.reading = reading
        self.furigana = furigana
    }
}
