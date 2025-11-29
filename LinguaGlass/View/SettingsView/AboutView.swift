//
//  AboutView.swift
//  LinguaGlass
//
//  Created by Steven Tran on 11/29/25.
//

import SwiftUI

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
