//
//  ImageOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//
// https://github.com/juanj/KantanManga/blob/development/MangaReader/OCR/ImageOCR.swift

import Foundation
import UIKit

protocol ImageOCR {
    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void)
}
