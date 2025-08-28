//
//  HeaderViewModel.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import Foundation

class HeaderViewModel: ObservableObject {
    @Published var isSearchBarHidden: Bool = false
    @Published var isOCRModeActive: Bool = false
    @Published var isLiveTextModeActive: Bool = false
    @Published var ocrMode: OCRMode = .inactive
    
    func toggleSearchBar() {
        isSearchBarHidden.toggle()
    }
    
    func toggleOCRMode() {
        isOCRModeActive.toggle()
        // Deactivate other modes when one is activated
        if isOCRModeActive {
            isLiveTextModeActive = false
        }
    }
    
    func toggleLiveTextMode() {
        isLiveTextModeActive.toggle()
        // Deactivate other modes when one is activated
        if isLiveTextModeActive {
            isOCRModeActive = false
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
