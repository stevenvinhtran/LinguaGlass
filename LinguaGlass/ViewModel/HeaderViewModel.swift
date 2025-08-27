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
}
