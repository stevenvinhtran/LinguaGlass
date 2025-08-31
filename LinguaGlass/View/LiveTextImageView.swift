//
//  LiveTextImageView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/30/25.
//

import VisionKit
import UIKit
import SwiftUI

struct LiveTextImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        if #available(iOS 16.0, *) {
            let interaction = ImageAnalysisInteraction()
            interaction.preferredInteractionTypes = .automatic
            imageView.addInteraction(interaction)

            let analyzer = ImageAnalyzer()
            Task {
                if let analysis = try? await analyzer.analyze(image, configuration: .init([.text])) {
                    interaction.analysis = analysis
                }
            }
        }

        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

