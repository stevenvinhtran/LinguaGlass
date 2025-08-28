//
//  OCRService.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import UIKit
import WebKit

class OCRCaptureService {
    private let ocrService: ImageOCR
    
    init(ocrService: ImageOCR = OCRService(settings: SettingsViewModel().settings)) {
        self.ocrService = ocrService
    }
    
    func captureOCRImage(from rect: CGRect, in webView: WKWebView, completion: @escaping (Result<String, Error>) -> Void) {
        webView.takeSnapshot(with: nil) { [weak self] image, error in
            guard let self = self else { return }
            
            guard let image = image, error == nil else {
                completion(.failure(error ?? NSError(domain: "OCRCapture", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to capture screenshot"])))
                return
            }
            
            if let croppedImage = self.cropImage(image, to: rect) {
                self.processImageWithOCR(croppedImage, completion: completion)
            } else {
                completion(.failure(NSError(domain: "OCRCapture", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image"])))
            }
        }
    }
    
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
    }
    
    private func processImageWithOCR(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        ocrService.recognize(image: image, completion)
    }
}
