//
//  OCRSelectionOverlayView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

struct OCRSelectionOverlayView: View {
    let selectionRect: CGRect?
    
    var body: some View {
        ZStack {
            if let rect = selectionRect {
                let minSize: CGFloat = 1
                let clampedWidth = max(rect.width, minSize)
                let clampedHeight = max(rect.height, minSize)
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
                    .background(Color.blue.opacity(0.2))
                    .frame(width: clampedWidth, height: clampedHeight)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }
}
