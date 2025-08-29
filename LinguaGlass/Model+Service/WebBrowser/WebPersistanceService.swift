//
//  WebPersistanceService.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

protocol WebPersistenceServiceProtocol {
    func saveLastURL(_ url: URL?)
    func loadLastURL() -> URL?
    func saveHistory(_ history: [WebPage])
    func loadHistory() -> [WebPage]
}

final class WebPersistenceService: WebPersistenceServiceProtocol {
    private let lastURLKey = "WebBrowserLastURL"
    private let historyKey = "WebBrowserHistory"
    
    func saveLastURL(_ url: URL?) {
        if let url = url {
            UserDefaults.standard.set(url.absoluteString, forKey: lastURLKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastURLKey)
        }
    }
    
    func loadLastURL() -> URL? {
        guard let urlString = UserDefaults.standard.string(forKey: lastURLKey) else {
            return nil
        }
        return URL(string: urlString)
    }
    
    func saveHistory(_ history: [WebPage]) {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    func loadHistory() -> [WebPage] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([WebPage].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }
}
