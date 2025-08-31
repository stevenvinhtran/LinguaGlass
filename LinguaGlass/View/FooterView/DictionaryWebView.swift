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
    let language: Language
    @Binding var isPresented: Bool
    @State private var webView: WKWebView?
    @State private var progress: Double = 0.0
    @State private var isLoading: Bool = false
    
    // Compute URL directly from props
    private var computedURL: URL? {
        let sanitizedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchTerm
        let dictionaryURL: String
        switch language {
        case .japaneseVertical, .japaneseHorizontal:
            dictionaryURL = "https://jisho.org/search/\(sanitizedTerm)"
        case .korean:
            dictionaryURL = "https://korean.dict.naver.com/koendict/#/search?query=\(sanitizedTerm)"
        case .vietnamese:
            dictionaryURL = "https://tracau.vn/?s=\(sanitizedTerm)"
        }
        return URL(string: dictionaryURL)
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

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        // Allow pinch zoom
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

        // Progress observer
        webView.addObserver(context.coordinator,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)

        webView.load(URLRequest(url: url))
        self.webView = webView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(progress: $progress, isLoading: $isLoading)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
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
    }
}


