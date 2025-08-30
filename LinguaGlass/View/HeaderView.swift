// HeaderView.swift
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
                        viewModel.toggleLiveTextMode()
                    }
                }) {
                    Image(systemName: "camera")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.isLiveTextModeActive ? .blue : .primary)
                        .frame(width: 36, height: 36)
                        .background(viewModel.isLiveTextModeActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Hide Search Bar Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleSearchBar()
                    }
                }) {
                    Image(systemName: viewModel.isSearchBarHidden ? "menubar.rectangle" : "menubar.dock.rectangle")
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
