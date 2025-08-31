//
//  HeaderView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: HeaderViewModel
    @ObservedObject var webViewModel: WebBrowserViewModel
    @Binding var showProgress: Bool
    var onSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // OCR Selection Mode Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleOCRMode()
                    }
                }) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(viewModel.isOCRModeActive ? .blue : .primary)
                        .frame(width: 44, height: 44)
                        .background(viewModel.isOCRModeActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Live Text Image Mode Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleLiveTextMode(for: webViewModel.webView)
                    }
                }) {
                    Image(systemName: "camera")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.isLiveTextModeActive ? .blue : .primary)
                        .frame(width: 36, height: 36)
                        .background(viewModel.isLiveTextModeActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Processing Indicator when OCR/tokenization is happening
                if viewModel.isProcessing {
                    ProgressView()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 4)
                }
                
                if viewModel.isLiveTextModeActive {
                    Spacer()
                    Text("Live Text")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .transition(.opacity)
                    Spacer()
                } else {
                    Spacer()
                }
                
                // Hide Footer Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleFooter()
                    }
                }) {
                    Image(systemName: viewModel.isFooterHidden ? "menubar.rectangle" : "menubar.dock.rectangle")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                // Hide Search Bar Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleSearchBar()
                    }
                }) {
                    Image(systemName: viewModel.isSearchBarHidden ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                // Settings Button
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            
            // Browser controls
            if !viewModel.isSearchBarHidden {
                WebBrowserControlsView(viewModel: webViewModel, showProgress: $showProgress)
            }
        }
    }
}
