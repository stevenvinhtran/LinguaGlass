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
        switch settings.targetLanguage {
        case .japaneseVertical, .chineseSimplifiedVertical, .chineseTraditionalVertical:
            // Map app Language to TesseractOCR.Language and use Tesseract only for vertical scripts
            let tesseractLanguage: TesseractOCR.Language?
            switch settings.targetLanguage {
            case .japaneseVertical: tesseractLanguage = .japaneseVertical
            case .chineseSimplifiedVertical: tesseractLanguage = .chineseSimplifiedVertical
            case .chineseTraditionalVertical: tesseractLanguage = .chineseTraditionalVertical
            default: tesseractLanguage = nil
            }
            if let tesseractLanguage {
                let tesseractOCR = TesseractOCR(language: tesseractLanguage)
                tesseractOCR.recognize(image: image, completion)
            } else {
                recognizeWithVision(image: image, completion: completion)
            }
            
        default:
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
        
        configureVisionRequest(request, for: settings.targetLanguage)
        
        // Perform the request on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func configureVisionRequest(_ request: VNRecognizeTextRequest, for language: TargetLanguage) {
        request.recognitionLevel = .accurate
        
        switch language {
        case .japaneseHorizontal:
            request.recognitionLanguages = ["ja"]
            request.usesLanguageCorrection = true
            request.recognitionLevel = .accurate
            
        case .korean:
            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true
            
        case .vietnamese:
            request.recognitionLanguages = ["vi"]
            request.usesLanguageCorrection = true

        case .spanish:
            request.recognitionLanguages = ["es"]
            request.usesLanguageCorrection = true
            
        case .french:
            request.recognitionLanguages = ["fr"]
            request.usesLanguageCorrection = true
            
        case .portuguese:
            request.recognitionLanguages = ["pt"]
            request.usesLanguageCorrection = true
            
        case .chineseSimplifiedHorizontal:
            request.recognitionLanguages = ["zh-Hans"]
            request.usesLanguageCorrection = true
            
        case .chineseTraditionalHorizontal:
            request.recognitionLanguages = ["zh-Hant"]
            request.usesLanguageCorrection = true
            
        case .japaneseVertical, .chineseSimplifiedVertical, .chineseTraditionalVertical:
            // These cases should not reach here because they use TesseractOCR,
            // but fallback to Vision with base language codes if they do
            switch language {
            case .japaneseVertical:
                request.recognitionLanguages = ["ja"]
            case .chineseSimplifiedVertical:
                request.recognitionLanguages = ["zh-Hans"]
            case .chineseTraditionalVertical:
                request.recognitionLanguages = ["zh-Hant"]
            default:
                break
            }
            request.usesLanguageCorrection = true
            
        case .italian:
            request.recognitionLanguages = ["it"]
            request.usesLanguageCorrection = true
            
        case .romanian:
            request.recognitionLanguages = ["ro"]
            request.usesLanguageCorrection = true
            
        case .english:
            request.recognitionLanguages = ["en"]
            request.usesLanguageCorrection = true

        case .other:
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
        }
        
        // Allow per-case control of language detection
        // request.usesLanguageCorrection remains true per-case where set
        if language != .other {
            request.automaticallyDetectsLanguage = false
        }
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
        
        completion(.success(recognizedText))
    }
    
}

enum OCRError: Error {
    case invalidImage
    case noResults
    case recognitionFailed
    case languageNotSupported
}
