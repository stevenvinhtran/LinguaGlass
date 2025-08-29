//
//  WebPage.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

struct WebPage: Codable {
    let url: URL
    let title: String?
    let lastVisited: Date
}
