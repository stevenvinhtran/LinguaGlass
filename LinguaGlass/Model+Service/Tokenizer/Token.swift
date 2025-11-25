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
    let rubyText: [RubyText]?

    init(
        text: String,
        dictionaryForm: String? = nil,
        reading: String? = nil,
        rubyText: [RubyText]? = nil
    ) {
        self.text = text
        self.dictionaryForm = dictionaryForm
        self.reading = reading
        self.rubyText = rubyText
    }
}
