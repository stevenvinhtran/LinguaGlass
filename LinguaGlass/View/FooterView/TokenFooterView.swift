//
//  TokenFooterView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/29/25.
//  Original Idea: https://github.com/juanj/KantanManga

import SwiftUI

struct TokenFooter: View {
    @ObservedObject var viewModel: TokenFooterViewModel
    @ObservedObject var headerViewModel: HeaderViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @FocusState private var isTextFieldFocused: Bool

    public static let footerHeight = 100.0
    public static let dictionaryHeight = UIScreen.main.bounds.height / 2
    private let horizontalPadding = 8.0
    private let buttonPadding = 8.0

    private var hasToken: Bool { viewModel.selectedToken != nil }
    private var spring: Animation { .spring(response: 0.4, dampingFraction: 0.85) }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmer
            if viewModel.showDictionary && hasToken {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(spring) {
                            viewModel.showDictionary = false
                        }
                    }
            }

            // Dictionary sheet
            if let token = viewModel.selectedToken {
                DictionaryWebView(
                    searchTerm: token.text,
                    language: settingsViewModel.settings.selectedLanguage,
                    isPresented: $viewModel.showDictionary
                )
                .frame(height: Self.dictionaryHeight)
                .background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)))
                .shadow(radius: 5)
                .offset(y: viewModel.showDictionary ? 0 : Self.dictionaryHeight)
                .animation(spring, value: viewModel.showDictionary)
                .zIndex(0) // behind footer
            }

            // Footer
            VStack(spacing: 0) {
                Divider()
                ZStack {
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
            // Move footer up when dictionary is shown
            .offset(y: viewModel.showDictionary ? -Self.dictionaryHeight : 0)
            .animation(spring, value: viewModel.showDictionary)
            .zIndex(1) // always above dictionary
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: viewModel.isEditing, initial: false) { _, editing in
            isTextFieldFocused = editing
        }
        .onChange(of: isTextFieldFocused, initial: false) { _, focused in
            if !focused && viewModel.isEditing {
                viewModel.commitEditing(headerViewModel: headerViewModel,
                                        settingsViewModel: settingsViewModel)
            }
        }
        .onChange(of: settingsViewModel.settings.selectedLanguage) {
            Task {
                if (try? TokenizerHandler.makeTokenizer(using: settingsViewModel.settings)) != nil {
                    await viewModel.tokenize(from: viewModel.editText,
                                             headerViewModel: headerViewModel,
                                             settingsViewModel: settingsViewModel)
                }
            }
        }
    }

    // MARK: - Subviews

    private var editModeView: some View {
        HStack {
            TextField("Enter text...", text: $viewModel.editText, axis: .horizontal)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.black)
                .frame(height: Self.footerHeight)
                .padding(.horizontal, horizontalPadding + buttonPadding)
                .focused($isTextFieldFocused)
                .onSubmit {
                    viewModel.commitEditing(headerViewModel: headerViewModel,
                                            settingsViewModel: settingsViewModel)
                }
                .submitLabel(.done)
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.commitEditing(headerViewModel: headerViewModel,
                                        settingsViewModel: settingsViewModel)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .bold))
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
                        } onDictionary: { token in
                            viewModel.showDictionary(for: token)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding + 26)
            }
        }
        .overlay(alignment: .topLeading) {
            VStack(spacing: 0) {
                Button {
                    viewModel.pasteFromClipboard(headerViewModel: headerViewModel,
                                                 settingsViewModel: settingsViewModel)
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(buttonPadding)
                
                Spacer()
                
                Button {
                    viewModel.searchAllTokens(settingsViewModel: settingsViewModel)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(buttonPadding)
                
                Spacer()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.beginEditing()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 20, weight: .semibold))
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
