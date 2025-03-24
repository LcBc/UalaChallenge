//
//  CityListView.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import SwiftUI

struct CityListView: View {

    @ObservedObject var viewModel: CityListViewModelImpl
    @State private var searchText = ""
    var showHideButton: Bool
    var toggleListVisibility: (() -> Void)?

    var body: some View {
        VStack {
            HStack{
                SearchBar(text: $searchText)
                if showHideButton,
                   let toggle = toggleListVisibility {
                    Button(action: toggle) {
                        Image(systemName: "sidebar.leading")
                            .padding()
                    }
                }
            } .background(Color(UIColor.systemBackground))
            Toggle(
                "Show Favorites Only",
                isOn: $viewModel.showFavoritesOnly
            )
            .padding(.horizontal)
            .background(Color(UIColor.systemBackground))
            Text(
                "Results: \(viewModel.filteredCities.count)"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            ScrollView {
                LazyVStack(
                    spacing: 0
                ) {
                    ForEach(
                        viewModel.filteredCities, id: \.id
                    ) { city in
                        Button(
                            action: {
                                viewModel.selectedCity = city
                            }
                        ) {
                            CityCell(
                                city: city,
                                viewModel: viewModel
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .background(
                    Color(
                        UIColor.systemGroupedBackground
                    )
                )
            }
            .background(Color(UIColor.systemBackground))
        }.onChange(
            of: searchText
        ) {
            viewModel.searchCity(text: searchText)
        }
        .onAppear {
            Task {
                try? await viewModel.getCities()
            }
        }
        .background(Color(UIColor.systemBackground))
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

        let viewModel = CityListViewModelImpl(
            cityApiService: mockService
        )
        return  NavigationStack {

            CityListView(
                viewModel: viewModel, showHideButton: false
            )
        }
    }
}
