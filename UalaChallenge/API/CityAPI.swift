//
//  CityApi.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import Foundation
import CoreData

protocol CityApiService {
    func fetchCities() async throws -> [City]
    func fetchFavoriteCities() async throws -> [City]
    func addCityToFavorites(_ city: City) async throws
    func removeCityFromFavorites(_ city: City) async throws
    func isCityInFavorites(_ city: City)  async throws -> Bool

}

class CityApiServiceImpl: CityApiService {

    enum URLStrings {
        static let citiesURLString = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
    }

    let session: URLSessionProtocol
    let context: NSManagedObjectContext
    private var cities: [City] = []

    init(
        session: URLSessionProtocol = URLSession.shared,
        context: NSManagedObjectContext
    ) {
        self.session = session
        self.context = context
    }


    func fetchCities() async throws -> [City] {

        guard let url = URL(
            string: URLStrings.citiesURLString
        ) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([City].self, from: data)
    }

    func fetchFavoriteCities() async throws -> [City] {

        if cities.isEmpty {
            cities = try await fetchCities()
        }

        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        let favoriteCities = try context.fetch(request)
        let favoriteIDs = Set(
            favoriteCities.map {
                Int($0.id)
            }
        )
        
        return cities.filter {
            favoriteIDs.contains($0.id)
        }
    }

    func addCityToFavorites(
        _ city: City
    ) async throws {
        let favoriteCity = FavoriteCity(
            context: context
        )
        favoriteCity.id = Int64(city.id)
        try context.save()
    }

    func removeCityFromFavorites(
        _ city: City
    ) async throws {
        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %d", city.id
        )
        let results = try context.fetch(request)
        for object in results {
            context.delete(object)
        }
        try context.save()
    }

    func isCityInFavorites(
        _ city: City
    ) async throws -> Bool {
        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %d", city.id
        )
        let count = try context.count(for: request)
        return count > 0
    }
}
