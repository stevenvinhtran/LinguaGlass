//
//  OCROptions.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import UIKit

enum OCRMode {
    case inactive
    case active
    case selecting(start: CGPoint, current: CGPoint)
}

struct OCRSelection {
    var rect: CGRect
    var image: UIImage?
}
