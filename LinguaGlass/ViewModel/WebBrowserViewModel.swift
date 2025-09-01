//
//  WebBrowserViewModel.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation
import WebKit
import Combine

protocol WebBrowserViewModelProtocol: ObservableObject {
    var state: WebBrowserState { get }
    var searchText: String { get set }
    var history: [WebPage] { get }
    var webView: WKWebView { get }
    
    func performSearch()
    func loadURL(_ url: URL?)
    func goBack()
    func goForward()
    func refresh()
    func stopLoading()
}

final class WebBrowserViewModel: NSObject, WebBrowserViewModelProtocol, WKUIDelegate {
    @Published private(set) var state = WebBrowserState()
    @Published var searchText: String = ""
    @Published private(set) var history: [WebPage] = []
    
    let webView: WKWebView
    private var cancellables = Set<AnyCancellable>()
    private let persistenceService: WebPersistenceServiceProtocol
    private var currentSearchTask: Task<Void, Never>?
    
    init(persistenceService: WebPersistenceServiceProtocol = WebPersistenceService()) {
        self.persistenceService = persistenceService
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        super.init()
        
        setupWebView()
        loadLastSession()
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // Force-enable pinch zoom
        webView.scrollView.pinchGestureRecognizer?.isEnabled = true

        // Inject JS to override viewport meta tag restrictions
        let js = """
        var meta = document.querySelector('meta[name=viewport]');
        if (meta) {
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes');
        } else {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
            document.head.appendChild(meta);
        }
        """
        let userScript = WKUserScript(source: js,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)

        // Observe loading state and progress
        webView.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.state.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.state.estimatedProgress = progress
            }
            .store(in: &cancellables)
        
        // Observe URL changes to update search bar
        webView.publisher(for: \.url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.updateSearchTextFromURL(url)
            }
            .store(in: &cancellables)
    }
    
    private func loadLastSession() {
        if let lastURL = persistenceService.loadLastURL() {
            loadURL(lastURL)
        } else {
            loadURL(URL(string: "https://www.google.com"))
        }
        
        history = persistenceService.loadHistory()
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Cancel any previous search task
        currentSearchTask?.cancel()
        
        // Create new search task
        currentSearchTask = Task {
            // Check if it looks like a URL (contains dot, no spaces)
            if self.isPotentialURL(query) {
                // Try to ping the URL first
                if await self.pingURL(query) {
                    // URL is valid, load it
                    if let url = self.parseURL(from: query) {
                        await MainActor.run {
                            self.loadURL(url)
                        }
                    }
                    return
                }
            }
            
            // If URL ping failed or doesn't look like URL, do Google search
            await MainActor.run {
                self.search(query: query)
            }
        }
    }
    
    private func isPotentialURL(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic checks: contains dot, no spaces, not starting/ending with dot
        return !trimmed.isEmpty &&
               trimmed.contains(".") &&
               !trimmed.contains(" ") &&
               !trimmed.hasPrefix(".") &&
               !trimmed.hasSuffix(".")
    }
    
    private func pingURL(_ text: String) async -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create URL (add https:// if missing)
        var urlString = trimmed
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        
        guard let url = URL(string: urlString) else {
            return false
        }
        
        // Create URLRequest with short timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0 // 3 second timeout
        request.httpMethod = "HEAD" // HEAD request is faster than GET
        
        do {
            // Try to make a request
            let (_, response) = try await URLSession.shared.data(for: request)
            
            // Check if we got a successful HTTP response (200-399)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...399).contains(httpResponse.statusCode)
            }
            
            return false
        } catch {
            // Request failed - not a valid URL
            return false
        }
    }
    
    private func updateSearchTextFromURL(_ url: URL?) {
        guard let url = url else {
            searchText = ""
            return
        }
        
        searchText = url.absoluteString
    }
    
    private func parseURL(from text: String) -> URL? {
        var urlString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add https:// if missing
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        
        return URL(string: urlString)
    }
    
    func loadURL(_ url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func refresh() {
        webView.reload()
    }
    
    func stopLoading() {
        webView.stopLoading()
    }
    
    func search(query: String) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        if let url = URL(string: "https://www.google.com/search?q=\(searchQuery)") {
            loadURL(url)
        }
    }
    
    private func updateNavigationState() {
        state.canGoBack = webView.canGoBack
        state.canGoForward = webView.canGoForward
    }
    
    private func saveToHistory(url: URL, title: String?) {
        let webPage = WebPage(url: url, title: title, lastVisited: Date())
        
        history.removeAll { $0.url == url }
        history.insert(webPage, at: 0)
        
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        persistenceService.saveHistory(history)
        persistenceService.saveLastURL(url)
    }
}

// MARK: - WKNavigationDelegate
extension WebBrowserViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationState()
        
        if let url = webView.url {
            saveToHistory(url: url, title: webView.title)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateNavigationState()
        state.currentURL = webView.url
    }
}
