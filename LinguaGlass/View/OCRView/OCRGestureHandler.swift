//
//  OCRGestureHandler.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

struct OCRGestureHandler: UIViewRepresentable {
    @ObservedObject var headerViewModel: HeaderViewModel
    var onSelectionComplete: (CGRect) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        // Add gesture recognizer
        let dragGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDrag(_:)))
        dragGesture.delegate = context.coordinator
        view.addGestureRecognizer(dragGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update gesture recognizer enabled state based on OCR mode
        uiView.gestureRecognizers?.forEach { gesture in
            gesture.isEnabled = headerViewModel.isOCRModeActive
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: OCRGestureHandler
        private var startPoint: CGPoint?
        
        init(_ parent: OCRGestureHandler) {
            self.parent = parent
        }
        
        @objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
            guard parent.headerViewModel.isOCRModeActive else { return }
            
            let location = gesture.location(in: gesture.view)
            
            switch gesture.state {
            case .began:
                startPoint = location
                parent.headerViewModel.startOCRSelection(at: location)
                
            case .changed:
                if let start = startPoint {
                    parent.headerViewModel.updateOCRSelection(to: location)
                }
                
            case .ended, .cancelled:
                if let start = startPoint, let rect = parent.headerViewModel.getSelectionRect() {
                    // Only complete if selection is large enough
                    if rect.width > 20 && rect.height > 20 {
                        parent.onSelectionComplete(rect)
                    }
                }
                startPoint = nil
                parent.headerViewModel.completeOCRSelection()
                
            default:
                break
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard parent.headerViewModel.isOCRModeActive else { return }
            
            // Cancel OCR selection on tap
            parent.headerViewModel.cancelOCRSelection()
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Allow simultaneous recognition with web view gestures
            return true
        }
    }
}
