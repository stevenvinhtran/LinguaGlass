//
//  TokenFooterView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//  Original Idea: https: //github.com/juanj/KantanManga

import SwiftUI

struct TokenFooter: View {
    @ObservedObject var viewModel: TokenFooterViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    public static let footerHeight = 100.0
    private let horizontalPadding = 8.0
    private let buttonPadding = 8.0
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            ZStack {
                // Background blur effect
                VisualEffectView(effect: UIBlurEffect(style: .light))
                
                if viewModel.isEditing {
                    editModeView
                } else {
                    displayModeView
                }
            }
            .frame(height: Self.footerHeight)
            .background(Color.gray.opacity(0.1))
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: viewModel.isEditing, initial: false) { _, editing in
            if editing {
                isTextFieldFocused = true
            } else {
                isTextFieldFocused = false
            }
        }
        .onChange(of: isTextFieldFocused, initial: false) { _, focused in
            if !focused && viewModel.isEditing {
                // User tapped away from keyboard, commit changes
                viewModel.commitEditing(settingsViewModel: settingsViewModel)
            }
        }
        .onChange(of: settingsViewModel.settings.selectedLanguage) {
            Task {
                if (try? TokenizerHandler.makeTokenizer(using: settingsViewModel.settings)) != nil {
                    await viewModel.tokenize(from: viewModel.editText, settingsViewModel: settingsViewModel)
                }
            }
        }
    }
    
    private var editModeView: some View {
        HStack {
            TextField("Enter text...", text: $viewModel.editText, axis: .horizontal)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.black)
                .frame(height: TokenFooter.footerHeight)
                .padding(.horizontal, horizontalPadding + buttonPadding)
                .padding(.top, 8.0)
                .focused($isTextFieldFocused)
                .onSubmit {
                    viewModel.commitEditing(settingsViewModel: settingsViewModel)
                }
                .submitLabel(.done)
            
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.commitEditing(settingsViewModel: settingsViewModel)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(buttonPadding)
        }
    }
    
    private var displayModeView: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.tokens) { token in
                        WordButton(
                            token: token,
                            isSelected: viewModel.selectedTokenID == token.id
                        ) {
                            viewModel.selectedTokenID = token.id
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding - 2)
            }
        }
        .overlay(alignment: .topLeading) {
            Button {
                viewModel.pasteFromClipboard(settingsViewModel: settingsViewModel)
            } label: {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .padding(buttonPadding)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.beginEditing()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .padding(buttonPadding)
        }
    }
}

// Blur effect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
