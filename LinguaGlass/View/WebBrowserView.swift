//
//  WebBrowserView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI
import WebKit

struct WebBrowserView: View {
    @StateObject var viewModel: WebBrowserViewModel
    @ObservedObject var headerViewModel: HeaderViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var tokenFooterViewModel: TokenFooterViewModel

    @State var showProgress: Bool
    @State var ocrCaptureService: OCRCaptureService
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // WebView content
                WebViewRepresentable(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.bottom)
                    .allowsHitTesting(!tokenFooterViewModel.isEditing)
            }
            
            // OCR Gesture Handler Overlay
            OCRGestureHandler(headerViewModel: headerViewModel) { selectionRect in
                captureOCRImage(from: selectionRect)
            }
            .allowsHitTesting(headerViewModel.isOCRModeActive && !tokenFooterViewModel.isEditing)
            
            // OCR Visual Overlay
            OCRSelectionOverlayView(selectionRect: headerViewModel.getSelectionRect())
        }
        .onChange(of: tokenFooterViewModel.isEditing, initial: false) { _, isEditing in
            if isEditing {
                if headerViewModel.isOCRModeActive {
                    headerViewModel.isOCRModeActive = false
                }
            }
        }
    }
    
    private func captureOCRImage(from rect: CGRect) {
        ocrCaptureService.captureOCRImage(from: rect, in: viewModel.webView) { result in
            switch result {
            case .success(let text):
                print("OCR Result: \(text)")
                Task {
                    await tokenFooterViewModel.tokenize(from: text, settingsViewModel: settingsViewModel)
                }

            case .failure(let error):
                print("OCR Error: \(error.localizedDescription)")
            }
        }
    }
}

struct WebBrowserControlsView: View {
    @ObservedObject var viewModel: WebBrowserViewModel
    @Binding var showProgress: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar and Navigation Controls
            HStack(spacing: 12) {
                // Navigation Controls
                HStack(spacing: 16) {
                    Button(action: { viewModel.goBack() }) {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(viewModel.state.canGoBack ? .blue : .gray)
                    }
                    .disabled(!viewModel.state.canGoBack)
                    
                    Button(action: { viewModel.goForward() }) {
                        Image(systemName: "arrow.forward")
                            .foregroundColor(viewModel.state.canGoForward ? .blue : .gray)
                    }
                    .disabled(!viewModel.state.canGoForward)
                    
                    Button(action: {
                        if viewModel.state.isLoading {
                            viewModel.stopLoading()
                        } else {
                            viewModel.refresh()
                        }
                    }) {
                        Image(systemName: viewModel.state.isLoading ? "xmark" : "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading, 8)
                
                // Search Bar
                SearchBarView(
                    text: $viewModel.searchText,
                    isLoading: viewModel.state.isLoading,
                    onSubmit: {
                        viewModel.performSearch()
                    }
                )
                
                if viewModel.state.isLoading {
                    ProgressView()
                        .frame(width: 16, height: 16)
                        .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Progress Bar
            if viewModel.state.isLoading {
                ProgressView(value: viewModel.state.estimatedProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 2)
                    .animation(.easeInOut, value: viewModel.state.estimatedProgress)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: WebBrowserViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        return viewModel.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // View updates are handled by the ViewModel through the webView property
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    let isLoading: Bool
    var onSubmit: (() -> Void)?
    
    var body: some View {
        TextField("Search or enter website address", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .keyboardType(.webSearch)
            .submitLabel(.go)
            .onSubmit {
                onSubmit?()
            }
    }
}

struct NavigationControlsView: View {
    let canGoBack: Bool
    let canGoForward: Bool
    let isLoading: Bool
    let onBack: () -> Void
    let onForward: () -> Void
    let onRefresh: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(canGoBack ? .blue : .gray)
            }
            .disabled(!canGoBack)
            
            Button(action: onForward) {
                Image(systemName: "arrow.forward")
                    .foregroundColor(canGoForward ? .blue : .gray)
            }
            .disabled(!canGoForward)
            
            Spacer()
            
            Button(action: isLoading ? onStop : onRefresh) {
                Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 18, weight: .semibold))
    }
}
