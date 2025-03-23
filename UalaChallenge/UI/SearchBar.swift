//
//  SearchBar.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $text)
                    .foregroundColor(.primary)

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 10)
        }
        .padding(.top, 8)
        .background(Color(UIColor.systemBackground)) // Ensures the background extends to the edges.
    }
}
