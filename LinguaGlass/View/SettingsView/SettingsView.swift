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
    @State private var showingDictionaries = false
    @Binding var showTutorial: Bool
    
    private var targetLanguageBinding: Binding<TargetLanguage> {
        Binding(
            get: { viewModel.settings.targetLanguage },
            set: { newLanguage in
                viewModel.settings.targetLanguage = newLanguage
                viewModel.saveSettings(viewModel.settings)
            }
        )
    }
    
    private var appLanguageBinding: Binding<AppLanguage> {
        Binding(
            get: { viewModel.settings.appLanguage },
            set: { newAppLang in
                viewModel.settings.appLanguage = newAppLang
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

    private var newTabBehaviorBinding: Binding<NewTabBehavior> {
        Binding(
            get: { viewModel.settings.newTabBehavior },
            set: { newBehavior in
                viewModel.settings.newTabBehavior = newBehavior
                viewModel.saveSettings(viewModel.settings)
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Language Section
                Section(header: Text("Language")) {
                    Picker("App Language", selection: appLanguageBinding) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Target Language", selection: targetLanguageBinding) {
                        ForEach(TargetLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("Note: OCR for vertical scripts and tokenization for Japanese may be inaccurate.")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: themeBinding) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Link Handling Section
                Section(header: Text("Links & Tabs")) {
                    Picker("Open new‑tab links", selection: newTabBehaviorBinding) {
                        ForEach(NewTabBehavior.allCases) { behavior in
                            Text(behavior.displayName).tag(behavior)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
                    
                    Button(action: { showingDictionaries = true }) {
                        HStack {
                            Text("Dictionaries")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showingDictionaries) {
                        DictionariesView()
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

