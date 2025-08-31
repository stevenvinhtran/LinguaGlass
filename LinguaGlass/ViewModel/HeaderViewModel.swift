//
//  HeaderViewModel.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation
import SwiftUI
import WebKit

class HeaderViewModel: ObservableObject {
    @Published var isSearchBarHidden: Bool = false
    @Published var isOCRModeActive: Bool = false
    @Published var isLiveTextModeActive: Bool = false
    @Published var ocrMode: OCRMode = .inactive
    @Published var isFooterHidden: Bool = false
    @Published var isProcessing: Bool = false
    @Published var liveTextImage: UIImage? = nil
    
    func toggleSearchBar() {
        isSearchBarHidden.toggle()
    }
    
    func toggleFooter() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFooterHidden.toggle()
        }
    }
    
    func toggleOCRMode() {
        isOCRModeActive.toggle()
        if isOCRModeActive {
            isLiveTextModeActive = false
        }
    }
    
    func toggleLiveTextMode(for webView: WKWebView) {
        if isLiveTextModeActive {
            isLiveTextModeActive = false
            liveTextImage = nil
            webView.scrollView.isScrollEnabled = true
            webView.isUserInteractionEnabled = true
        } else {
            isLiveTextModeActive = true
            isOCRModeActive = false

            // Capture screenshot
            let config = WKSnapshotConfiguration()
            config.rect = webView.bounds
            webView.takeSnapshot(with: config) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        self.liveTextImage = image
                        // Disable gestures on webView
                        webView.scrollView.isScrollEnabled = false
                        webView.isUserInteractionEnabled = false
                    }
                }
            }
        }
    }

    
    func startOCRSelection(at point: CGPoint) {
        ocrMode = .selecting(start: point, current: point)
    }
    
    func updateOCRSelection(to point: CGPoint) {
        if case .selecting(let start, _) = ocrMode {
            ocrMode = .selecting(start: start, current: point)
        }
    }
    
    func completeOCRSelection() {
        isOCRModeActive = false
        ocrMode = .inactive
    }
    
    func cancelOCRSelection() {
        isOCRModeActive = false
        ocrMode = .inactive
    }
    
    func getSelectionRect() -> CGRect? {
        if case .selecting(let start, let current) = ocrMode {
            let origin = CGPoint(x: min(start.x, current.x), y: min(start.y, current.y))
            let size = CGSize(width: abs(current.x - start.x), height: abs(current.y - start.y))
            return CGRect(origin: origin, size: size)
        }
        return nil
    }
}
