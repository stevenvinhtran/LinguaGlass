//  I modified this file significantly
//  TesseractOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//  https://github.com/juanj/KantanManga/

import Foundation
import SwiftyTesseract
import UIKit

class TesseractOCR: ImageOCR {
    enum TesseractError: Error {
        case recognitionError
    }
    
    enum Language {
        case japaneseVertical
        case chineseSimplifiedVertical
        case chineseTraditionalVertical
    }
    
    private let tesseract: Tesseract
    private let pageSegmentationMode: PageSegmentationMode
    
    init(language: Language) {
        switch language {
        case .japaneseVertical:
            self.tesseract = Tesseract(language: .custom("jpn_vert"))
            self.pageSegmentationMode = .singleBlockVerticalText
        case .chineseSimplifiedVertical:
            self.tesseract = Tesseract(language: .custom("chi_sim_vert"))
            self.pageSegmentationMode = .singleBlockVerticalText
        case .chineseTraditionalVertical:
            self.tesseract = Tesseract(language: .custom("chi_tra_vert"))
            self.pageSegmentationMode = .singleBlockVerticalText
        }
    }

    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        tesseract.pageSegmentationMode = pageSegmentationMode
        DispatchQueue.global(qos: .utility).async {
            let result: Result<String, Tesseract.Error> = self.tesseract.performOCR(on: image)
            switch result {
            case .success(let text):
                completion(.success(text))
            case .failure:
                completion(.failure(TesseractError.recognitionError))
            }
        }
    }
}
