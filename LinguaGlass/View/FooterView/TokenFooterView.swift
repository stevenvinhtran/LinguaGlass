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

    // Live drag amount during gesture
    @GestureState private var dragTranslation: CGFloat = 0

    public static let footerHeight = 100.0
    public static let dictionaryHeight = UIScreen.main.bounds.height / 2
    private let horizontalPadding = 8.0
    private let buttonPadding = 8.0

    private var hasToken: Bool { viewModel.selectedToken != nil }
    private var spring: Animation { .spring(response: 0.4, dampingFraction: 0.85) }

    // Base offset for the dictionary when not dragging
    private var baseDictOffset: CGFloat {
        guard hasToken else { return Self.dictionaryHeight }  // treat as closed when no token
        return viewModel.showDictionary ? 0 : Self.dictionaryHeight
    }

    // Only apply drag when a token exists
    private var activeDrag: CGFloat {
        hasToken ? dragTranslation : 0
    }

    // Clamp to [0, dictionaryHeight]
    private var dictionaryYOffset: CGFloat {
        let raw = baseDictOffset + activeDrag
        return max(0, min(Self.dictionaryHeight, raw))
    }

    // Footer rides with visible dictionary height
    private var footerYOffset: CGFloat {
        -(Self.dictionaryHeight - dictionaryYOffset)
    }

    // 0 (closed) -> 1 (open); 0 if no token
    private var openProgress: CGFloat {
        guard hasToken else { return 0 }
        return 1 - (dictionaryYOffset / Self.dictionaryHeight)
    }

    // Drag gesture only when a token exists
    private var sheetDragGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let dragDistance = value.translation.height
                let dragVelocity = value.predictedEndTranslation.height - dragDistance

                // Current position in points from fully open
                let currentOffset = baseDictOffset + dragDistance

                // Decide based on position or velocity
                let shouldOpen: Bool
                if abs(dragVelocity) > 500 {
                    // Negative velocity = swipe up, Positive = swipe down
                    shouldOpen = dragVelocity < 0
                } else {
                    // Fallback to halfway rule
                    shouldOpen = currentOffset < Self.dictionaryHeight * 0.5
                }

                withAnimation(spring) {
                    viewModel.showDictionary = shouldOpen
                }
            }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmer only when a token exists and sheet is opening
            Color.black.opacity(openProgress > 0 ? 0.2 * openProgress : 0)
                .ignoresSafeArea()
                .allowsHitTesting(hasToken && openProgress > 0)
                .onTapGesture {
                    guard hasToken else { return }
                    withAnimation(spring) { viewModel.showDictionary = false }
                }

            // Dictionary sheet behind the footer
            if let token = viewModel.selectedToken {
                DictionaryWebView(
                    searchTerm: token.text,
                    language: settingsViewModel.settings.selectedLanguage,
                    isPresented: $viewModel.showDictionary
                )
                .frame(height: Self.dictionaryHeight)
                .background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)))
                .shadow(radius: 5)
                .offset(y: dictionaryYOffset)
                .highPriorityGesture(AnyGesture(sheetDragGesture))
                .accessibilityHidden(!viewModel.showDictionary)
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
                .contentShape(Rectangle())
                .onTapGesture {
                    guard hasToken else { return }
                    withAnimation(spring) { viewModel.showDictionary = true }
                }
            }
            .keyboardAdaptive(when: !viewModel.showDictionary)
            .offset(y: footerYOffset)
            // Only attach the drag gesture when a token exists, otherwise no gesture
            .highPriorityGesture(
                hasToken ? AnyGesture(sheetDragGesture) : nil
            )
            .zIndex(1)
        }
        .ignoresSafeArea(edges: .bottom)

        // Close the sheet if the token becomes nil
        .onChange(of: viewModel.selectedToken, initial: false) { _, token in
            if token == nil {
                withAnimation(spring) { viewModel.showDictionary = false }
            }
        }
        .onChange(of: viewModel.isEditing, initial: false) { _, editing in
            isTextFieldFocused = editing
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
                .onSubmit { viewModel.commitEditing(settingsViewModel: settingsViewModel) }
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
                        } onDictionary: { token in
                            viewModel.showDictionary(for: token)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding - 2)
            }
        }
        .overlay(alignment: .topLeading) {
            HStack(spacing: 0) {
                // Paste button
                Button {
                    viewModel.pasteFromClipboard(settingsViewModel: settingsViewModel)
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(buttonPadding)
                
                Button {
                    viewModel.searchAllTokens(settingsViewModel: settingsViewModel)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(buttonPadding)
            }
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
