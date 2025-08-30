//
//  TokenizerProtocol.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//

import Foundation

protocol TokenizerService {
    func tokenize(text: String) async throws -> [Token]
}
