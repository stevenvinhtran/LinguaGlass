//
//  OCRService.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

// OCRService.swift
import UIKit
import Vision

class OCRService: ImageOCR {
    private let settings: AppSettings
    private var currentRequests: [VNRequest] = []
    
    init(settings: AppSettings) {
        self.settings = settings
    }
    
    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        let tesseractOCR = TesseractOCR()
        
        switch settings.selectedLanguage {
        case .japaneseVertical:
            tesseractOCR.recognize(image: image, completion)
            
        case .japaneseHorizontal, .korean, .vietnamese:
            recognizeWithVision(image: image, completion: completion)
        }
    }
    
    private func recognizeWithVision(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            self?.handleVisionResults(request: request, error: error, completion: completion)
        }
        
        configureVisionRequest(request, for: settings.selectedLanguage)
        
        // Perform the request on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func configureVisionRequest(_ request: VNRecognizeTextRequest, for language: Language) {
        request.recognitionLevel = .accurate
        
        switch language {
        case .japaneseHorizontal:
            request.recognitionLanguages = ["ja"]
            request.usesLanguageCorrection = true
            
        case .korean:
            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true
            
        case .vietnamese:
            request.recognitionLanguages = ["vi"]
            request.usesLanguageCorrection = true
            
        case .japaneseVertical:
            // Shouldn't reach here, but fallback
            request.recognitionLanguages = ["ja"]
            request.usesLanguageCorrection = true
        }
        
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = false
    }
    
    private func handleVisionResults(request: VNRequest, error: Error?, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            completion(.failure(OCRError.noResults))
            return
        }
        
        let recognizedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: "\n")
        
        let cleanText = cleanVisionOutput(recognizedText, for: settings.selectedLanguage)
        
        completion(.success(cleanText))
    }
    
    private func cleanVisionOutput(_ output: String, for language: Language) -> String {
        var cleanText = output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch language {
        case .japaneseHorizontal, .japaneseVertical:
            var notAllowed = CharacterSet.decimalDigits
            notAllowed.formUnion(CharacterSet("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ".unicodeScalars))
            notAllowed.formUnion(CharacterSet(#"-_/\()|〔〕[]{}%:<>"#.unicodeScalars))
            
            let cleanUnicodeScalars = cleanText
                .replacingOccurrences(of: "\n", with: "  ")
                .unicodeScalars
                .filter { !notAllowed.contains($0) }
            cleanText = String(cleanUnicodeScalars)
            
        case .korean:
            var notAllowed = CharacterSet.decimalDigits
            notAllowed.formUnion(CharacterSet("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ".unicodeScalars))
            notAllowed.formUnion(CharacterSet(#"-_/\()|〔〕[]{}%:<>"#.unicodeScalars))
            
            let cleanUnicodeScalars = cleanText
                .replacingOccurrences(of: "\n", with: "  ")
                .unicodeScalars
                .filter { !notAllowed.contains($0) }
            cleanText = String(cleanUnicodeScalars)
            
        case .vietnamese:
            // Remove only symbols and numbers, keep Latin letters
            var notAllowed = CharacterSet.decimalDigits
            notAllowed.formUnion(CharacterSet(#"-_/\()|〔〕[]{}%:<>"#.unicodeScalars))
            
            let cleanUnicodeScalars = cleanText
                .replacingOccurrences(of: "\n", with: "  ")
                .unicodeScalars
                .filter { !notAllowed.contains($0) }
            cleanText = String(cleanUnicodeScalars)
        }
        return cleanText
    }
}

enum OCRError: Error {
    case invalidImage
    case noResults
    case recognitionFailed
    case languageNotSupported
}
