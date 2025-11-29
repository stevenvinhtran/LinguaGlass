//
//  OCRGestureHandler.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

private final class PressGestureRecognizer: UILongPressGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        minimumPressDuration = 0
        allowableMovement = .greatestFiniteMagnitude
        cancelsTouchesInView = true
    }
}

struct OCRGestureHandler: UIViewRepresentable {
    @ObservedObject var headerViewModel: HeaderViewModel
    var onSelectionComplete: (CGRect) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        // Unified immediate press+drag recognizer
        let pressPan = PressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePressPan(_:)))
        pressPan.delegate = context.coordinator
        view.addGestureRecognizer(pressPan)
        
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
        
        private func clampedLocation(from gesture: UIGestureRecognizer) -> CGPoint {
            let location = gesture.location(in: gesture.view)
            guard let view = gesture.view else { return location }
            let bounds = view.bounds
            let x = max(bounds.minX, min(location.x, bounds.maxX))
            let y = max(bounds.minY, min(location.y, bounds.maxY))
            return CGPoint(x: x, y: y)
        }
        
        private func beginSelection(at location: CGPoint) {
            startPoint = location
            parent.headerViewModel.startOCRSelection(at: location)
        }
        
        private func updateSelection(to location: CGPoint) {
            if startPoint != nil {
                parent.headerViewModel.updateOCRSelection(to: location)
            }
        }
        
        private func endSelection(at location: CGPoint) {
            defer { startPoint = nil }

            // If we have a valid large-enough rect, complete and deactivate
            if let rect = parent.headerViewModel.getSelectionRect(), rect.width >= 20 && rect.height >= 20 {
                parent.onSelectionComplete(rect)
                parent.headerViewModel.completeOCRSelection()
                return
            }

            // Distinguish tap vs. small drag using movement distance
            if let start = startPoint {
                let dx = location.x - start.x
                let dy = location.y - start.y
                let movement = sqrt(dx*dx + dy*dy)
                let tapTolerance: CGFloat = 8
                if movement <= tapTolerance {
                    // Treat as tap: clear selection but keep OCR active
                    parent.headerViewModel.clearOCRSelection()
                    return
                }
            }

            // Too small after a drag: clear and deactivate OCR
            parent.headerViewModel.cancelOCRSelection()
        }
        
        @objc func handlePressPan(_ gesture: UILongPressGestureRecognizer) {
            guard parent.headerViewModel.isOCRModeActive else { return }
            let location = clampedLocation(from: gesture)
            switch gesture.state {
            case .began:
                beginSelection(at: location)
            case .changed:
                updateSelection(to: location)
            case .ended, .cancelled:
                endSelection(at: location)
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
            // While in OCR mode, prefer our gestures to avoid delays from competing recognizers
            return !parent.headerViewModel.isOCRModeActive
        }
    }
}

