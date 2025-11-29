//
//  DictionariesView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/29/25.
//

import SwiftUI

struct DictionaryRow: View {
    let language: LocalizedStringKey
    let link: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(language)
                .font(.headline)
            Text(link)
                .font(.subheadline)
        }
        .padding(.vertical, 8)
    }
}

struct DictionariesView: View {
    @Environment(\.dismiss) private var dismiss
    private let sanitizedTerm = "SEARCH_TERM"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DictionaryRow(
                        language: "Japanese",
                        link: "https://jisho.org/search/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Korean",
                        link: "https://korean.dict.naver.com/koendict/#/search?query=\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Vietnamese",
                        link: "https://tracau.vn/?s=\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Spanish",
                        link: "https://www.spanishdict.com/translate/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "French",
                        link: "https://www.frenchdictionary.com/translate/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Portuguese",
                        link: "https://dictionary.reverso.net/portuguese-english/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Italian",
                        link: "https://dictionary.reverso.net/italian-english/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Romanian",
                        link: "https://dictionary.reverso.net/romanian-english/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Chinese",
                        link: "https://hanzii.net/search/word/\(sanitizedTerm)?hl=en"
                    )
                    
                    DictionaryRow(
                        language: "English",
                        link: "https://www.dictionary.com/browse/\(sanitizedTerm)"
                    )
                    
                    DictionaryRow(
                        language: "Other",
                        link: "https://translate.google.com/?sl=auto&tl=en&text=\(sanitizedTerm)&op=translate"
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dictionaries")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
