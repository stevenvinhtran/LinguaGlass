//
//  AcknowledgementView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/29/25.
//

import SwiftUI

struct AcknowledgementRow: View {
    let name: String
    let description: String
    let link: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let link = link {
                Text(link)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AcknowledgementsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AcknowledgementRow(
                        name: "Kantan Manga by Juan Meneses",
                        description: "Heavily inspired LinguaGlass. Much code was borrowed/inspired from its github.",
                        link: "https://github.com/juanj/KantanManga"
                    )
                    
                    AcknowledgementRow(
                        name: "SwiftyTesseract by Steven Sherry",
                        description: "Vertical Japanese text recognition.",
                        link: "https://github.com/SwiftyTesseract/SwiftyTesseract"
                    )
                    
                    AcknowledgementRow(
                        name: "Mecab by Nara Institute of Science and Technology / Taku Kudou",
                        description: "Japanese word tokenizer and furigana converter",
                        link: "https://github.com/taku910/mecab"
                    )
                    
                    AcknowledgementRow(
                        name: "Mecab-Swift by shinjukunian",
                        description: "Mecab wrapper for Swift",
                        link: "https://github.com/shinjukunian/Mecab-Swift"
                    )
                    
                    AcknowledgementRow(
                        name: "DongDu by Luu Tuan Anh",
                        description: "Inspriation for Vietnamese word tokenization. Vietnamese syllable list taken from github.",
                        link: "https://github.com/rockkhuya/DongDu"
                    )
                    
                    AcknowledgementRow(
                        name: "VNEDICT by Paul Denisowski",
                        description: "Vietnamese wordlist used for tokenization",
                        link: "http://www.denisowski.org/Vietnamese/Vietnamese.html"
                    )
                    
                    AcknowledgementRow(
                        name: "WWJavaScriptContext_Pinyin by William Weng",
                        description: "Chinese pinyin converter",
                        link: "https://github.com/William-Weng/WWJavaScriptContext_Pinyin"
                    )
                    
                    AcknowledgementRow(
                        name: "Saint☆Young Men by Hikaru Nakamura - Creative Commons",
                        description: "Manga used in App Store images",
                        link: nil
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Acknowledgements")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

