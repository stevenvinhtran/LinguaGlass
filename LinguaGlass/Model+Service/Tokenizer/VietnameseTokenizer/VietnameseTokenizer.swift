//
//  VietnameseTokenizer.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/31/25.
//  Original idea: https://github.com/rockkhuya/DongDu/blob/master/src/data/VNsyl.txt

import Foundation

final class VietnameseTokenizer: TokenizerService {
    private let maxCompoundLength: Int
    private let wordSet: Set<String>
    private let syllableSet: Set<String>
    
    public init(
        // http://www.denisowski.org/Vietnamese/Vietnamese.html (VNEDICT Vietnamese-English Dictionary (utf-8 text file) modified)
        wordFile: String = "vietnamese_wordlist",
        // https://github.com/rockkhuya/DongDu/blob/master/src/data/VNsyl.txt
        syllableFile: String = "vietnamese_syllables",
        maxCompoundLength: Int = 8
    ) throws {
        self.maxCompoundLength = maxCompoundLength
        
        func loadLines(_ name: String) throws -> [String] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "txt") else {
                throw NSError(
                    domain: "VietnameseTokenizer",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing \(name).txt"]
                )
            }
            let raw = try String(contentsOf: url)
            return raw
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }
        }
        
        let words = try loadLines(wordFile)
        let sylls = try loadLines(syllableFile)
        
        self.wordSet = Set(words)
        self.syllableSet = Set(sylls)
    }
    
    func tokenize(text: String) async throws -> [Token] {
        // 1. Split input into “syllables” on whitespace
        let original = text
        let lowered = original.lowercased()
        let rawSylls = lowered
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        let n = rawSylls.count
        
        // 2. Build DP table: dp[i] = (minPenalty, nextIndex)
        //    penalty = 0 for a dictionary word, 1 for fallback syllable
        var dp = Array(repeating: (penalty: Int.max, next: n), count: n + 1)
        dp[n] = (0, n)
        
        // fill from i = n-1 down to 0
        for i in stride(from: n - 1, through: 0, by: -1) {
            let limit = min(n, i + maxCompoundLength)
            
            // try longest first so we pick the longest valid compound
            for j in stride(from: limit, to: i, by: -1) {
                let candidate = rawSylls[i..<j].joined(separator: " ")
                let isWord = wordSet.contains(candidate)
                let isSyll = (j == i + 1 && syllableSet.contains(candidate))
                
                if isWord || isSyll {
                    let cost = dp[j].penalty + (isWord ? 0 : 1)
                    if cost < dp[i].penalty {
                        dp[i] = (cost, j)
                    }
                }
            }
            
            // if nothing matched at all (typos, foreign), force single syllable
            if dp[i].penalty == Int.max {
                dp[i] = (dp[i + 1].penalty + 1, i + 1)
            }
        }
        
        // 3. Reconstruct tokens with their original String ranges
        var tokens: [Token] = []
        var idx = 0
        var cursor = original.startIndex
        
        while idx < n {
            // skip over any whitespace in the original string
            while cursor < original.endIndex && original[cursor].isWhitespace {
                cursor = original.index(after: cursor)
            }
            
            let next = dp[idx].next
            let syllableSlice = rawSylls[idx..<next].joined(separator: " ")
            let length = syllableSlice.count
            
            // capture the exact substring from the original text
            let end = original.index(cursor, offsetBy: length, limitedBy: original.endIndex) ?? original.endIndex
            let range = cursor..<end
            let substr = String(original[range])
            
            tokens.append(Token(text: substr))
            cursor = end
            idx = next
        }
        
        return tokens
    }
}
