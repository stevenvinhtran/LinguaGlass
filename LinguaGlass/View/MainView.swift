//
//  ContentView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var webViewModel = WebBrowserViewModel()
    @StateObject private var headerViewModel = HeaderViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showSettings = false
    @State private var showProgress = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                viewModel: headerViewModel,
                webViewModel: webViewModel,
                showProgress: $showProgress, 
                onSettings: {
                    showSettings.toggle()
                }
            )
            
            WebBrowserView(
                viewModel: webViewModel,
                headerViewModel: headerViewModel,
                showProgress: showProgress,
                ocrCaptureService: OCRCaptureService(settingsViewModel: settingsViewModel)
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.getColorScheme())
        }
        .preferredColorScheme(settingsViewModel.getColorScheme())
    }
}

#Preview {
    MainView()
}
