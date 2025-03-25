//
//  FavoriteButton.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//
import SwiftUI

struct FavoriteButton<ViewModel>: View where ViewModel: CityListViewModel {
    var city: City
    @ObservedObject var viewModel: ViewModel
    @State private var isFavorite: Bool = false

    var body: some View {
        Button(action: {
            Task {
                await toggleFavorite()
            }
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .gray)
        }
        .onAppear {
            Task {
                isFavorite = await isCityFavorite()
            }
        }
    }

    private func toggleFavorite() async {
        if isFavorite {
            try? await viewModel.removeFromFavorite(city: city)?.value
        } else {
            try? await viewModel.addToFavorite(city: city)?.value
        }
        isFavorite.toggle()
    }

    private func isCityFavorite() async -> Bool {
        do {
            return try await viewModel.isFavorite(city: city)?.value ?? false
        } catch {
            return false
        }
    }
}
