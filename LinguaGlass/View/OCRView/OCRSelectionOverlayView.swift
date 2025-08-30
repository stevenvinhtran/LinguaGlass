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
            if let rect = selectionRect, rect.width > 5, rect.height > 5 {
                // Selection rectangle
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
                    .background(Color.blue.opacity(0.2))
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }
}
