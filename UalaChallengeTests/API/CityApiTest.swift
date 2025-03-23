//
//  CityApiTest.swift
//  UalaChallengeTests
//
//  Created by Luis Barrios on 20/3/25.
//

import XCTest
import CoreData
@testable import UalaChallenge

final class CityApiTest: XCTestCase {

    var cityService: CityApiServiceImpl!
    var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        // Initialize in-memory persistent container
        persistentContainer = NSPersistentContainer(
            name: "UalaChallengeDataModel"
        )
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }

        cityService = CityApiServiceImpl(context: persistentContainer.viewContext)
    }

    override func tearDown() {
        cityService = nil
        persistentContainer = nil
        super.tearDown()
    }


    func testFetchCities() async throws {
        // Given
        let expectedCity = City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates: Coordinates(
                latitude: 44.549999,
                longitude: 34.283333
            )
        )

        let jsonData = """
               [
                   {
                       "country": "UA",
                       "name": "Hurzuf",
                       "_id": 707860,
                       "coord": {
                           "lon": 34.283333,
                           "lat": 44.549999
                       }
                   }
               ]
               """.data(using: .utf8)!

        let urlSessionMock = URLSessionMock(
            data: jsonData,
            response: nil,
            error: nil
        )
        cityService = CityApiServiceImpl(
            session: urlSessionMock,
            context: persistentContainer.viewContext
        )

        // When
        let cities = try await cityService.fetchCities()

        // Then
        XCTAssertEqual(cities.count, 1)
        XCTAssertEqual(cities.first, expectedCity)
    }


    func testFetchCitiesWithError() async throws {
        // Given
        let urlSessionMock = URLSessionMock(
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )
        cityService = CityApiServiceImpl(
            session: urlSessionMock,
            context: persistentContainer.viewContext
        )

        // When & Then
        do {
            _ = try await cityService.fetchCities()
            XCTFail("Expected to throw an error but did not")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    func testFetchCitiesWithBadData() async throws {
        // Given
        let badJsonData = "Invalid JSON".data(using: .utf8)!
        let urlSessionMock = URLSessionMock(
            data: badJsonData,
            response: nil,
            error: nil
        )
        cityService = CityApiServiceImpl(
            session: urlSessionMock,
            context: persistentContainer.viewContext
        )

        // When & Then
        do {
            _ = try await cityService.fetchCities()
            XCTFail("Expected to throw a decoding error but did not")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testFetchFavoriteCitiesWhenEmpty() async throws {
        // Given
        let jsonData = """
          [
              {
                  "country": "UA",
                  "name": "Hurzuf",
                  "_id": 707860,
                  "coord": {
                      "lon": 34.283333,
                      "lat": 44.549999
                  }
              }
          ]
          """.data(using: .utf8)!

        let urlSessionMock = URLSessionMock(data: jsonData, response: nil, error: nil)
        cityService = CityApiServiceImpl(session: urlSessionMock, context: persistentContainer.viewContext)

        // When
        let favoriteCities = try await cityService.fetchFavoriteCities()

        // Then
        XCTAssertTrue(favoriteCities.isEmpty)
    }

    func testFetchFavoriteCitiesWithMultipleFavorites() async throws {
        // Given
        let jsonData = """
          [
              {
                  "country": "UA",
                  "name": "Hurzuf",
                  "_id": 707860,
                  "coord": {
                      "lon": 34.283333,
                      "lat": 44.549999
                  }
              },
              {
                  "country": "US",
                  "name": "New York",
                  "_id": 5128581,
                  "coord": {
                      "lon": -74.006,
                      "lat": 40.7143
                  }
              }
          ]
          """.data(using: .utf8)!

        let urlSessionMock = URLSessionMock(data: jsonData, response: nil, error: nil)
        cityService = CityApiServiceImpl(session: urlSessionMock, context: persistentContainer.viewContext)

        let hurzuf = City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates:
                Coordinates(
                    latitude: 44.549999,
                    longitude: 34.283333
                )
        )

        let newYork = City(
            name: "New York",
            id: 5128581,
            country: "US",
            coordinates:
                Coordinates(
                    latitude: 40.7143,
                    longitude: -74.006
                )
        )
        try await cityService.addCityToFavorites(hurzuf)
        try await cityService.addCityToFavorites(newYork)

        // When
        let favoriteCities = try await cityService.fetchFavoriteCities()

        // Then
        XCTAssertEqual(favoriteCities.count, 2)
        XCTAssertTrue(favoriteCities.contains(hurzuf))
        XCTAssertTrue(favoriteCities.contains(newYork))
    }

    func testFetchFavoriteCitiesWithSingleFavorites() async throws {
        // Given
        let jsonData = """
          [
              {
                  "country": "UA",
                  "name": "Hurzuf",
                  "_id": 707860,
                  "coord": {
                      "lon": 34.283333,
                      "lat": 44.549999
                  }
              },
              {
                  "country": "US",
                  "name": "New York",
                  "_id": 5128581,
                  "coord": {
                      "lon": -74.006,
                      "lat": 40.7143
                  }
              }
          ]
          """.data(using: .utf8)!

        let urlSessionMock = URLSessionMock(data: jsonData, response: nil, error: nil)
        cityService = CityApiServiceImpl(session: urlSessionMock, context: persistentContainer.viewContext)

        let hurzuf = City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates:
                Coordinates(
                    latitude: 44.549999,
                    longitude: 34.283333
                )
        )

        let newYork = City(
            name: "New York",
            id: 5128581,
            country: "US",
            coordinates:
                Coordinates(
                    latitude: 40.7143,
                    longitude: -74.006
                )
        )

        try await cityService.addCityToFavorites(hurzuf)

        // When
        let favoriteCities = try await cityService.fetchFavoriteCities()

        // Then
        XCTAssertEqual(favoriteCities.count, 1)
        XCTAssertTrue(favoriteCities.contains(hurzuf))
        XCTAssertFalse(favoriteCities.contains(newYork))
    }

    func testFetchCitiesWithURLError() async throws {
           // Given
           let urlSessionMock = URLSessionMock(data: nil, response: nil, error: URLError(.notConnectedToInternet))
           cityService = CityApiServiceImpl(session: urlSessionMock, context: persistentContainer.viewContext)

           // When & Then
           do {
               _ = try await cityService.fetchFavoriteCities()
               XCTFail("Expected to throw an error but did not")
           } catch {
               XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
           }
       }

    func testAddCityToFavorites() async throws {
        // Given
        let city =  City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates: Coordinates(
                latitude: 44.549999,
                longitude: 34.283333
            )
        )

        // When
        try await cityService.addCityToFavorites(city)

        // Then
        let isFavorite = try await cityService.isCityInFavorites(city)
        XCTAssertTrue(isFavorite)
    }

    func testAddDuplicateCityToFavorites() async throws {
        // Given
        let city =  City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates: Coordinates(
                latitude: 44.549999,
                longitude: 34.283333
            )
        )

        try await cityService.addCityToFavorites(city)
        try await cityService.addCityToFavorites(city)
        // When
        let favoriteCities = try await cityService.fetchFavoriteCities()

        // Then
        let isFavorite = try await cityService.isCityInFavorites(city)
        XCTAssertTrue(isFavorite)
        XCTAssertEqual(favoriteCities.count, 1)
    }

    func testRemoveCityFromFavorites() async throws {
        // Given
        let city =  City(
            name: "Hurzuf",
            id: 707860,
            country: "UA",
            coordinates: Coordinates(
                latitude: 44.549999,
                longitude: 34.283333
            )
        )

        try await cityService.addCityToFavorites(city)

        // When
        try await cityService.removeCityFromFavorites(city)

        // Then
        let isFavorite = try await cityService.isCityInFavorites(city)
        XCTAssertFalse(isFavorite)
    }
}
