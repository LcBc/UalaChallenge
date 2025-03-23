//
//  MockCityApiService.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import Foundation

class MockCityApiService: CityApiService {

    var cities: [City] = []
    var favoriteCities: Set<Int> = []
    var shouldThrowError: Bool = false

    func fetchCities() async throws -> [City] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "fetchCitiesFailed"])
        }
        return cities
    }

    func fetchFavoriteCities() async throws -> [City] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 2, userInfo: [NSLocalizedDescriptionKey: "fetchFavoriteCitiesFailed"])
        }
        return cities.filter {
            favoriteCities.contains($0.id)
        }
    }

    func addCityToFavorites(_ city: City) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 3, userInfo: [NSLocalizedDescriptionKey: "addCityToFavoritesFailed"])
        }
        favoriteCities.insert(city.id)
    }

    func removeCityFromFavorites(_ city: City) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 4, userInfo: [NSLocalizedDescriptionKey: "removeCityFromFavoritesFailed"])
        }
        favoriteCities.remove(city.id)
    }

    func isCityInFavorites(_ city: City) async throws -> Bool {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 5, userInfo: [NSLocalizedDescriptionKey: "isCityInFavorites"])
        }
        return favoriteCities.contains(city.id)
    }
}
