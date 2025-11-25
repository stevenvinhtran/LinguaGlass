//
//  ChineseUtils.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/25/25.
//

import Foundation
import WWJavaScriptContext
import WWJavaScriptContext_Pinyin

public class ChineseUtils {
    
    static func unicodeScalarToString(_ scalar: String.UnicodeScalarView.Element) -> String {
        return String(scalar)
    }
    static func getPinyin(text: String) -> [RubyText] {
        guard !text.isEmpty else {
            return []
        }
        
        var rubyTexts: [RubyText] = []
        
        let scalars = text.unicodeScalars
        var startIndex: String.Index? = nil
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            let scalar = text.unicodeScalars[text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: text.distance(from: text.startIndex, to: currentIndex))]
            
            if scalar.properties.isIdeographic {
                // Start or continue a Han substring
                if startIndex == nil {
                    startIndex = currentIndex
                }
            } else {
                // End current Han substring if any
                if let start = startIndex {
                    let end = currentIndex
                    let substring = String(text[start..<end])
                    if let pinyin = pinyin(for: substring) {
                        let range = start..<end
                        let ruby = RubyText(ruby: pinyin, range: range)
                        rubyTexts.append(ruby)
                    }
                    startIndex = nil
                }
            }
            
            currentIndex = text.index(after: currentIndex)
        }
        
        // Handle trailing Han substring at end of string
        if let start = startIndex {
            let end = text.endIndex
            let substring = String(text[start..<end])
            if let pinyin = pinyin(for: substring) {
                let range = start..<end
                let ruby = RubyText(ruby: pinyin, range: range)
                rubyTexts.append(ruby)
            }
        }
        
        return rubyTexts
    }
    
    private static func pinyin(for text: String) -> String? {
        let mutable = NSMutableString(string: text) as CFMutableString
        
        // Transform to Pinyin with tone marks
        if !CFStringTransform(mutable, nil, kCFStringTransformMandarinLatin, false) {
            return nil
        }
        
        // Do not strip combining marks to keep tone marks.
        // Collapse multiple whitespaces and trim.
        let pinyinString = (mutable as String)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return pinyinString.isEmpty ? nil : pinyinString
    }
}
