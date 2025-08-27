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
                
                // Reset Section
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        viewModel.resetToDefaults()
                        viewModel.applyTheme()
                    }
                }
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

// Placeholder views for About and Acknowledgements
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("About LinguaGlass")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("LinguaGlass is a powerful language learning tool that combines OCR technology with text tokenization to help you read and understand foreign languages more effectively.")
                        .foregroundColor(.secondary)
                    
                    Text("Features:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "text.viewfinder", text: "OCR text extraction from web content")
                        FeatureRow(icon: "text.word.spacing", text: "Advanced tokenization for Asian languages")
                        FeatureRow(icon: "book.closed", text: "Integrated dictionary lookup")
                        FeatureRow(icon: "eye", text: "Multiple theme support")
                    }
                    
                    Spacer()
                }
                .padding()
            }
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
                    Text("Acknowledgements")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("LinguaGlass makes use of several open-source libraries and technologies:")
                        .foregroundColor(.secondary)
                    
                    AcknowledgementRow(
                        name: "Apple Vision Framework",
                        description: "For OCR text recognition capabilities",
                        license: "Apple SDK License"
                    )
                    
                    AcknowledgementRow(
                        name: "SwiftUI",
                        description: "For the modern user interface",
                        license: "Apple SDK License"
                    )
                    
                    AcknowledgementRow(
                        name: "WKWebView",
                        description: "For web content rendering",
                        license: "Apple SDK License"
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
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}

struct AcknowledgementRow: View {
    let name: String
    let description: String
    let license: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(license)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
