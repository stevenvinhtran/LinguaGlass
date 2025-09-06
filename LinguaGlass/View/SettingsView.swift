//
//  SettingsView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 8/27/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAbout = false
    @State private var showingAcknowledgements = false
    @Binding var showTutorial: Bool
    
    private var languageBinding: Binding<Language> {
        Binding(
            get: { viewModel.settings.selectedLanguage },
            set: { newLanguage in
                viewModel.settings.selectedLanguage = newLanguage
                viewModel.saveSettings(viewModel.settings)
            }
        )
    }
    
    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { viewModel.settings.appTheme },
            set: { newTheme in
                viewModel.settings.appTheme = newTheme
                viewModel.applyTheme()
                viewModel.saveSettings(viewModel.settings)
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Language Section
                Section(header: Text("Language")) {
                    Picker("Select Language", selection: languageBinding) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("Note: Japanese tokenization and vertical OCR may be inaccurate. If OCR results are poor, use Live Text mode. If tokenization is incorrect, use “Search All” - Jisho.org applies its own tokenization.")
                        .font(.system(size: 7, weight: .light))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: themeBinding) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Info Section
                Section(header: Text("Information")) {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Text("About")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showingAbout) {
                        AboutView()
                    }
                    
                    Button(action: { showingAcknowledgements = true }) {
                        HStack {
                            Text("Acknowledgements")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showingAcknowledgements) {
                        AcknowledgementsView()
                    }
                }
                
                // Replay Tutorial Section
                Section {
                    Button("Replay Tutorial") {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                showTutorial = true
                            }
                        }
                    }
                }
                
                // Reset Section
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        viewModel.resetToDefaults()
                        viewModel.applyTheme()
                    }
                }
                
                
                Text("Contact the developer at linguaglass@gmail.com for bug reports or additional language support/feature requests.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(35)
                Spacer().frame(height: 10)
                Text("LinguaGlass")
                    .font(.system(size: 15))
                Text("(1.0.0)")
                    .font(.system(size: 15))
            }
            .padding()
            .navigationTitle("About")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct AcknowledgementsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AcknowledgementRow(
                        name: "Kantan Manga by Juan Meneses",
                        description: "Heavily inspired LinguaGlass. Much code was borrowed/inspired from its github.",
                        link: "https://github.com/juanj/KantanManga"
                    )
                    
                    AcknowledgementRow(
                        name: "SwiftyTesseract by Steven Sherry",
                        description: "Vertical Japanese text recognition.",
                        link: "https://github.com/SwiftyTesseract/SwiftyTesseract"
                    )
                    
                    AcknowledgementRow(
                        name: "Mecab by Nara Institute of Science and Technology / Taku Kudou",
                        description: "Japanese word tokenizer",
                        link: "https://github.com/taku910/mecab"
                    )
                    
                    AcknowledgementRow(
                        name: "Mecab-Swift by shinjukunian",
                        description: "Mecab wrapper for Swift",
                        link: "https://github.com/shinjukunian/Mecab-Swift"
                    )
                    
                    AcknowledgementRow(
                        name: "DongDu by Luu Tuan Anh",
                        description: "Inspriation for Vietnamese word tokenization. Vietnamese syllable list taken from github.",
                        link: "https://github.com/rockkhuya/DongDu"
                    )
                    
                    AcknowledgementRow(
                        name: "VNEDICT by Paul Denisowski",
                        description: "Vietnamese wordlist used for tokenization",
                        link: "http://www.denisowski.org/Vietnamese/Vietnamese.html"
                    )
                    
                    AcknowledgementRow(
                        name: "Saint☆Young Men by Hikaru Nakamura - Creative Commons",
                        description: "Manga used in App Store images",
                        link: nil
                    )
                    
                    Text("Dictionaries")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    AcknowledgementRow(
                        name: "Jisho",
                        description: "Japanese dictionary",
                        link: "https://jisho.org/"
                    )
                    
                    AcknowledgementRow(
                        name: "Naver Dictionary",
                        description: "Korean dictionary",
                        link: "https://korean.dict.naver.com/koendict/#/main"
                    )
                    
                    AcknowledgementRow(
                        name: "Tra câu",
                        description: "Vietnamese dictionary",
                        link: "https://tracau.vn/"
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Acknowledgements")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// Supporting views
struct AcknowledgementRow: View {
    let name: String
    let description: String
    let link: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let link = link {
                Text(link)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
