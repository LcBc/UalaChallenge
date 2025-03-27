//
//  UalaChallengeApp.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: createViewModel())
        }
    }

    private func createViewModel() -> some CityListViewModel {
        if CommandLine.arguments.contains("--uitesting") {
            let mockService = MockCityApiService()
            mockService.cities = [
                City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
                City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
                City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
            ]
            mockService.favoriteCities = [1]
            return CityListViewModelImpl(cityApiService: mockService)
        } else {
            return CityListViewModelImpl()
        }
    }
}

