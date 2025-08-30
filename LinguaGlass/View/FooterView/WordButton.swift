//
//  WordButton.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//  Original idea: https: //github.com/juanj/KantanManga

import Foundation
import SwiftUI

let mainFontSize = 55.0
let furiganaFontSize = 18.0

struct WordButton: View {
    let token: Token
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if let furigana = token.furigana, !furigana.isEmpty {
                FuriganaText(base: token.text, furigana: furigana)
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isSelected ? Color.black : Color.clear)
                    .cornerRadius(8)
            } else {
                // Add invisible furigana spacer to maintain consistent height
                VStack(spacing: 0) {
                    Text(" ")
                        .font(.system(size: furiganaFontSize))
                        .opacity(0)
                        .frame(height: 12) // Match furigana height
                    Text(token.text)
                        .font(.system(size: mainFontSize, weight: .semibold))
                }
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.black : Color.clear)
                .cornerRadius(8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct FuriganaText: View {
    let base: String
    let furigana: [Furigana]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(makeSegments(), id: \.id) { seg in
                VStack(spacing: 0) {
                    if let kana = seg.kana {
                        Text(kana)
                            .font(.system(size: furiganaFontSize))
                            .frame(height: 12)
                    } else {
                        Text(" ")
                            .font(.system(size: furiganaFontSize))
                            .opacity(0)
                            .frame(height: 12)
                    }
                    Text(seg.text)
                        .font(.system(size: mainFontSize, weight: .semibold))
                }
            }
        }
    }

    private func makeSegments() -> [Segment] {
        guard !base.isEmpty else { return [] }
        var result: [Segment] = []
        var cursor = base.startIndex

        let spans = furigana.sorted { $0.range.lowerBound < $1.range.lowerBound }

        for span in spans {
            if cursor < span.range.lowerBound {
                let plain = String(base[cursor..<span.range.lowerBound])
                for ch in plain {
                    result.append(Segment(text: String(ch), kana: nil))
                }
            }
            let chunk = String(base[span.range])
            result.append(Segment(text: chunk, kana: span.kana))
            cursor = span.range.upperBound
        }

        if cursor < base.endIndex {
            let tail = String(base[cursor..<base.endIndex])
            for ch in tail {
                result.append(Segment(text: String(ch), kana: nil))
            }
        }
        return result
    }

    private struct Segment: Identifiable {
        let id = UUID()
        let text: String
        let kana: String?
    }
}
