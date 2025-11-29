//
//  DictionaryWebView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/30/25.
//

import SwiftUI
import WebKit

struct DictionaryWebView: View {
    let searchTerm: String
    let language: TargetLanguage
    @Binding var isPresented: Bool
    @State private var webView: WKWebView?
    @State private var progress: Double = 0.0
    @State private var isLoading: Bool = false
    @Environment(\.locale) private var locale
    
    // Localize a template string using the SwiftUI environment locale
    private func localizedTemplate(for defaultTemplate: String) -> String {
        let key = defaultTemplate
        
        let identifier = locale.identifier
        let languageCode = locale.language.languageCode?.identifier
        
        let bundle: Bundle
        
        if let path = Bundle.main.path(forResource: identifier, ofType: "lproj"),
           let locBundle = Bundle(path: path) {
            bundle = locBundle
        } else if let languageCode,
                  let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
                  let locBundle = Bundle(path: path) {
            bundle = locBundle
        } else {
            bundle = .main
        }
        
        return NSLocalizedString(key,
                                 tableName: nil,
                                 bundle: bundle,
                                 value: defaultTemplate,
                                 comment: "")
    }
    
    // Compute URL directly from props
    private var computedURL: URL? {
        let sanitizedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        ?? searchTerm
        
        let template: String
        
        switch language {
        case .japaneseVertical, .japaneseHorizontal:
            template = localizedTemplate(for: "https://jisho.org/search/%@")
            
        case .korean:
            template = localizedTemplate(for: "https://korean.dict.naver.com/koendict/#/search?query=%@")
            
        case .vietnamese:
            template = localizedTemplate(for: "https://tracau.vn/?s=%@")
            
        case .spanish:
            template = localizedTemplate(for: "https://www.spanishdict.com/translate/%@")
            
        case .french:
            template = localizedTemplate(for: "https://www.frenchdictionary.com/translate/%@")
            
        case .portuguese:
            template = localizedTemplate(for: "https://dictionary.reverso.net/portuguese-english/%@")
            
        case .chineseSimplifiedHorizontal,
                .chineseSimplifiedVertical,
                .chineseTraditionalHorizontal,
                .chineseTraditionalVertical:
            template = localizedTemplate(for: "https://hanzii.net/search/word/%@?hl=en")
            
        case .italian:
            template = localizedTemplate(for: "https://dictionary.reverso.net/italian-english/%@")
            
        case .romanian:
            template = localizedTemplate(for: "https://dictionary.reverso.net/romanian-english/%@")
            
        case .english:
            template = localizedTemplate(for: "https://www.dictionary.com/browse/%@")
            
        case .other:
            template = localizedTemplate(for: "https://translate.google.com/?sl=auto&tl=en&text=%@&op=translate")
        }
        
        let urlString = String(format: template, sanitizedTerm)
        return URL(string: urlString)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if isLoading {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .background(.gray)
                    .tint(.blue)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
            
            // WebView
            if let url = computedURL {
                DictionaryWebViewRepresentable(url: url,
                                               webView: $webView,
                                               progress: $progress,
                                               isLoading: $isLoading)
                .edgesIgnoringSafeArea(.bottom)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
        .shadow(radius: 10)
    }
}



struct DictionaryWebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var webView: WKWebView?
    @Binding var progress: Double
    @Binding var isLoading: Bool
    
    // Track the last URL we explicitly loaded from SwiftUI
    private static var lastSearchURL: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        // Allow pinch zoom
        webView.scrollView.pinchGestureRecognizer?.isEnabled = true
        webView.scrollView.scrollsToTop = false
        
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
        
        // Progress observer
        webView.addObserver(context.coordinator,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        
        // Initial load
        webView.load(URLRequest(url: url))
        Self.lastSearchURL = url
        
        self.webView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if the incoming search URL is different from the last one we loaded
        if Self.lastSearchURL != url {
            uiView.load(URLRequest(url: url))
            Self.lastSearchURL = url
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(progress: $progress, isLoading: $isLoading)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        @Binding var progress: Double
        @Binding var isLoading: Bool
        
        init(progress: Binding<Double>, isLoading: Binding<Bool>) {
            _progress = progress
            _isLoading = isLoading
        }
        
        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress),
               let webView = object as? WKWebView {
                progress = webView.estimatedProgress
                isLoading = progress < 1.0
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
        
        // Handle target="_blank" links: open in same webView
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        
        // MARK: - WKUIDelegate
        
        // Handle window.open / new window requests: open in same webView
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}
