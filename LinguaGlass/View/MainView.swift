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

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                viewModel: headerViewModel,
                webViewModel: webViewModel,
                showProgress: $showProgress,
                onSettings: { showSettings.toggle() }
            )

            WebBrowserView(
                viewModel: webViewModel,
                headerViewModel: headerViewModel,
                settingsViewModel: settingsViewModel,
                tokenFooterViewModel: tokenFooterViewModel,
                showProgress: showProgress,
                ocrCaptureService: OCRCaptureService(settingsViewModel: settingsViewModel)
            )

            Spacer().frame(height: TokenFooter.footerHeight)
        }
        .overlay(alignment: .bottom) {
            TokenFooter(viewModel: tokenFooterViewModel, settingsViewModel: settingsViewModel)
                .keyboardAdaptive()
        }
        .onChange(of: webViewModel.state.isLoading, initial: false) { _, isLoading in
            showProgress = isLoading
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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

