//
//  KeyboardAdaptive.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/30/25.
//

import SwiftUI
import Combine

extension View {
    func keyboardAdaptive(when condition: Bool = true) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(dictionaryIsActive: condition))
    }
}

struct KeyboardAdaptive: ViewModifier {
    let dictionaryIsActive: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, dictionaryIsActive ? keyboardHeight : 0)
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            .animation(.easeOut(duration: 0.3), value: dictionaryIsActive)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
    }
}
