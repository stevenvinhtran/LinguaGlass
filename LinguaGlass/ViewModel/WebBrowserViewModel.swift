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
    
    // Store the last raw query the user entered
    private var lastRawQuery: String = ""
    
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
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)

        // Observe loading state and progress
        webView.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in self?.state.isLoading = isLoading }
            .store(in: &cancellables)
        
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in self?.state.estimatedProgress = progress }
            .store(in: &cancellables)
        
        // Observe URL changes to update search bar
        webView.publisher(for: \.url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in self?.updateSearchTextFromURL(url) }
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
        lastRawQuery = query
        
        // Cancel any previous search task
        currentSearchTask?.cancel()
        
        currentSearchTask = Task {
            if let url = URL(string: query), isValidHTTPURL(url) {
                await MainActor.run { self.loadURL(url) }
            } else if isBareDomain(query), let url = URL(string: "https://\(query)") {
                await MainActor.run { self.loadURL(url) }
            } else {
                await MainActor.run { self.search(query: query) }
            }
        }
    }
    
    private func isValidHTTPURL(_ url: URL) -> Bool {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = comps.scheme?.lowercased(),
              (scheme == "http" || scheme == "https"),
              let host = comps.host, !host.isEmpty
        else { return false }
        return true
    }
    
    private func isBareDomain(_ text: String) -> Bool {
        let pattern = #"^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,24}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func updateSearchTextFromURL(_ url: URL?) {
        guard let url = url else {
            searchText = ""
            return
        }
        
        searchText = url.absoluteString
    }
    
    func loadURL(_ url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func refresh() { webView.reload() }
    func stopLoading() { webView.stopLoading() }
    
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error)
    }
    
    private func handleLoadError(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet:
                // Use the original raw query, not the transformed URL
                search(query: lastRawQuery)
            default:
                break
            }
        }
    }
}
