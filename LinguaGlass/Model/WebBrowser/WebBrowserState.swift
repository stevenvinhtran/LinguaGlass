//
//  WebBrowserState.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

struct WebBrowserState: Codable {
    var currentURL: URL?
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var isLoading: Bool = false
    var estimatedProgress: Double = 0.0
}
