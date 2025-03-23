//
//  CityListView.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import SwiftUI

struct CitiesListView: View {
    @ObservedObject var viewModel: CityListViewModelImpl
    @State private var searchText = ""
    @State private var selectedCity: City?

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                Toggle("Show Favorites Only", isOn: $viewModel.showFavoritesOnly).padding(.horizontal)
                Text("Results: \(viewModel.filteredCities.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredCities, id: \.id) { city in
                            NavigationLink(value: city) {
                                CityCell(city: city, viewModel: viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .navigationDestination(for: City.self) { city in
                        EmptyView()
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }.onChange(of: searchText) {
                viewModel.searchCity(text: searchText)
            }.navigationTitle("Cities")
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            Task {
                try? await viewModel.getCities()
            }
        }
    }
}

struct CitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockService = MockCityApiService()
        mockService.cities = [
            City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 2, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockService.favoriteCities = [1]

        let viewModel = CityListViewModelImpl(cityApiService: mockService)
        return CitiesListView(viewModel: viewModel)
    }
}
