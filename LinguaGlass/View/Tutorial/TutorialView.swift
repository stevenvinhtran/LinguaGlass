//
//  TutorialView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 9/1/25.
//

import SwiftUI

struct TutorialView: View {
    @Binding var isShowing: Bool
    @State private var currentPage = 0
    
    let tutorialPages = [
        TutorialPage(
            title: "Welcome to LinguaGlass",
            description: "Your all-in-one language learning browser with OCR and dictionary lookup tools.",
            image: "hand.wave.fill",
            color: .blue
        ),
        TutorialPage(
            title: "Web Browsing",
            description: "Browse any website normally. Use the search bar to navigate or enter URLs.",
            image: "globe",
            color: .green
        ),
        TutorialPage(
            title: "OCR Text Selection",
            description: "Tap this icon, then drag to select text on any webpage for text extraction.",
            image: "viewfinder",
            color: .orange
        ),
        TutorialPage(
            title: "Live Text Mode",
            description: "Tap this icon to capture the page and use iOS Live Text to translate/copy text.",
            image: "camera",
            color: .purple
        ),
        TutorialPage(
            title: "Word Lookup",
            description: "Selected text appears in the footer. Tap words to see dictionary definitions.",
            image: "text.word.spacing",
            color: .red
        ),
        TutorialPage(
            title: "Paste Button",
            description: "Tap the clipboard to paste text into the footer.",
            image: "doc.on.clipboard",
            color: .yellow
        ),
        TutorialPage(
            title: "Search Sentence Button",
            description: "Tap the magnifying glass to lookup all the words in the footer.",
            image: "magnifyingglass",
            color: .indigo
        ),
        TutorialPage(
            title: "Edit Button",
            description: "Tap the pencil to edit the footer text.",
            image: "pencil",
            color: .teal
        ),
        TutorialPage(
            title: "Multi-Language Support",
            description: "Supports Japanese, Korean, and Vietnamese. Change language in settings.",
            image: "character.bubble",
            color: .gray
        )
    ]
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Progress dots with smoother animation
                HStack(spacing: 8) {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? tutorialPages[index].color : .gray.opacity(0.3))
                            .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 30)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        TutorialPageView(page: tutorialPages[index], isLastPage: index == tutorialPages.count - 1)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)
                
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    if currentPage < tutorialPages.count - 1 {
                        Button("Next") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                    } else {
                        Button("Get Started") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isShowing = false
                                UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .padding(.top, 20)
            }
        }
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let image: String
    let color: Color
}

struct TutorialPageView: View {
    let page: TutorialPage
    let isLastPage: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: page.image)
                    .font(.system(size: 70))
                    .foregroundColor(page.color)
                    .padding()
                    .background(page.color.opacity(0.1))
                    .clipShape(Circle())
                    .scaleEffect(isLastPage ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isLastPage)
                
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                
                // Add contact info only for the last page
                if isLastPage {
                    VStack() {
                        Text("Contact the developer at linguaglass@gmail.com for bug reports or additional language support/feature requests.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, 40)
        }
        .scrollIndicators(.hidden)
    }
}
