//
//  ContentView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI
import UIKit

struct MainView: View {
    @StateObject private var webViewModel = WebBrowserViewModel()
    @StateObject private var headerViewModel = HeaderViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var tokenFooterViewModel = TokenFooterViewModel()
    
    @State private var showSettings = false
    @State private var showProgress = false
    @State private var showTutorial = false
    
    var body: some View {
        ZStack {
            // Main app content
            VStack(spacing: 0) {
                HeaderView(
                    viewModel: headerViewModel,
                    webViewModel: webViewModel,
                    showProgress: $showProgress,
                    onSettings: { showSettings.toggle() }
                )
                
                GeometryReader { geo in
                    ZStack {
                        WebBrowserView(
                            viewModel: webViewModel,
                            headerViewModel: headerViewModel,
                            settingsViewModel: settingsViewModel,
                            tokenFooterViewModel: tokenFooterViewModel,
                            showProgress: showProgress,
                            ocrCaptureService: OCRCaptureService(settingsViewModel: settingsViewModel)
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(headerViewModel.isLiveTextModeActive ? 0 : 1)
                        
                        if headerViewModel.isLiveTextModeActive, let image = headerViewModel.liveTextImage {
                            LiveTextImageView(image: image)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .background(Color.clear)
                                .transition(.opacity)
                                .disabled(!headerViewModel.isLiveTextModeActive)
                        }
                    }
                }
                
                if !headerViewModel.isFooterHidden {
                    Spacer().frame(height: TokenFooter.footerHeight)
                }
            }
            .overlay(alignment: .bottom) {
                TokenFooter(viewModel: tokenFooterViewModel, headerViewModel: headerViewModel, settingsViewModel: settingsViewModel)
                    .keyboardAdaptive()
                    .opacity(headerViewModel.isFooterHidden ? 0 : 1)
                    .allowsHitTesting(!headerViewModel.isFooterHidden)
                    .animation(.easeInOut(duration: 0.3), value: headerViewModel.isFooterHidden)
            }
            
            if showTutorial {
                TutorialView(isShowing: $showTutorial)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            showTutorial = TutorialManager.shared.shouldShowTutorial
        }
        .onChange(of: webViewModel.state.isLoading, initial: false) { _, isLoading in
            showProgress = isLoading
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(showTutorial: $showTutorial)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.getColorScheme())
        }
        .preferredColorScheme(settingsViewModel.getColorScheme())
        .ignoresSafeArea(edges: .bottom)
    }
}

final class HostingController<Content: View>: UIHostingController<Content> {
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        // Keep the home indicator visible so the first swipe just dims it
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Require an extra swipe by delaying system gestures
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        // Defer system gestures on the bottom edge
        return [.bottom]
    }
}

struct UIKitWrapper<Content: View>: UIViewControllerRepresentable {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        HostingController(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

