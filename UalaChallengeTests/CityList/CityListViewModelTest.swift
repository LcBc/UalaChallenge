//
//  CityListViewModelTest.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import XCTest
@testable import UalaChallenge

@MainActor
final class CityListViewModelTests: XCTestCase {

    var viewModel: CityListViewModelImpl!
    var mockCityApiService: MockCityApiService!

    override func setUp() {
        super.setUp()
        mockCityApiService = MockCityApiService()
        viewModel = CityListViewModelImpl(cityApiService: mockCityApiService)
    }

    override func tearDown() {
        viewModel = nil
        mockCityApiService = nil
        super.tearDown()
    }

    func initialTasks() async {
        await viewModel.testable.initialTask?.value
        await viewModel.testable.getCitiesTask?.value
        await viewModel.testable.getFavoriteCitiesTask?.value
    }

    func testInitializationCalls() async throws {
        // Given
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]

        mockCityApiService = MockCityApiService()
        mockCityApiService.cities = cities

        // When
        viewModel = CityListViewModelImpl(cityApiService: mockCityApiService)
        await initialTasks()
        // Then


        XCTAssertNotNil(viewModel.testable.getFavoriteCitiesTask)
        XCTAssertNotNil(viewModel.testable.getCitiesTask)
        XCTAssertEqual(viewModel.filteredCities.map{ $0.name }, ["Los Angeles", "New York", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["USA", "Canada", "USA"])
    }

    func updateShowFavoritesCallsSearch() async throws {
        // Given
        await initialTasks()

        // When
        viewModel.showFavoritesOnly = true

        XCTAssertNotNil(viewModel.testable.getSearchTask)
    }

    func testGetCities() async throws {
        // Given
        let cities = [
            City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 2, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]

        mockCityApiService.cities = cities
        await initialTasks()
        // When
        try await viewModel.getCities()?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map{ $0.name }, ["Los Angeles", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["USA", "USA"])
    }

    func testGetCitiesWithError() async throws {
        // Given
        await initialTasks()
        mockCityApiService.shouldThrowError = true
        // When
        try await viewModel.getCities()?.value

        // Then
        XCTAssertTrue(viewModel.filteredCities.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "fetchCitiesFailed")
    }


    func testGetFavoriteCities() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 2, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getCities()?.value

        // When
        try await viewModel.getFavoriteCities()?.value
        viewModel.showFavoritesOnly = true
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map { $0.id }, [1])
    }

    func testGetFavoritesCitiesWithError() async throws {
        // Given
        await initialTasks()
        mockCityApiService.shouldThrowError = true

        // When
        try await viewModel.getFavoriteCities()?.value

        // Then
        XCTAssertTrue(viewModel.filteredCities.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "fetchFavoriteCitiesFailed")
    }

    func testAddToFavorite() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.cities = [city]
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getCities()?.value
        try await viewModel.getFavoriteCities()?.value

        // When
        try await viewModel.addToFavorite(city: city)?.value

        // Then
        XCTAssertTrue(viewModel.testable.favoriteCities.contains(city))
    }

    func testAddToFavoriteWithError() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))

        // When
        mockCityApiService.shouldThrowError = true
        try await viewModel.addToFavorite(city: city)?.value
        mockCityApiService.shouldThrowError = false
        // Then
        XCTAssertFalse(viewModel.testable.favoriteCities.contains(city))
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "addCityToFavoritesFailed")
    }

    func testRemoveFromFavorite() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.favoriteCities = [1]

        // When
        try await viewModel.removeFromFavorite(city: city)?.value

        // Then
        XCTAssertFalse(viewModel.testable.favoriteCities.contains(city))
    }

    func testRemoveFromFavoriteWhenShowFavoritesIsTrue() async throws {

        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.favoriteCities = [1]
        viewModel.showFavoritesOnly = true
        // When
        try await viewModel.removeFromFavorite(city: city)?.value

        // Then
        XCTAssertFalse(viewModel.testable.favoriteCities.contains(city))
        XCTAssertFalse(viewModel.filteredCities.contains(city))

    }

    func testRemoveFromFavoriteError() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.cities = [city]
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getCities()?.value
        try await viewModel.getFavoriteCities()?.value
        mockCityApiService.shouldThrowError = true

        // When

        try await viewModel.removeFromFavorite(city: city)?.value

        // Then
        XCTAssertTrue(viewModel.testable.favoriteCities.contains(city))
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "removeCityFromFavoritesFailed")
    }

    func testIsFavorite() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.favoriteCities = [1]

        // When
        let isFavorite = try await viewModel.isFavorite(city: city)?.value

        // Then
        XCTAssertTrue(isFavorite ?? false)
    }

    func testIsFavoriteError() async throws {
        // Given
        await initialTasks()
        let city = City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060))
        mockCityApiService.favoriteCities = [1]
        mockCityApiService.shouldThrowError = true

        // When
        let isFavorite = try await viewModel.isFavorite(city: city)?.value

        // Then
        XCTAssertFalse(isFavorite ?? true)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "isCityInFavorites")
    }

    func testSearchCityWithMatches() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        mockCityApiService.favoriteCities = [1]
        viewModel.showFavoritesOnly = false
        await viewModel.testable.getSearchTask?.value
        try await viewModel.getCities()?.value

        // When
        viewModel.searchCity(text: "New")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map { $0.name }, ["New York", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["Canada","USA"])
    }

    func testSearchCityWithMatchesIsCaseSensitive() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        mockCityApiService.favoriteCities = [1]
        viewModel.showFavoritesOnly = false
        await viewModel.testable.getSearchTask?.value
        try await viewModel.getCities()?.value

        // When
        viewModel.searchCity(text: "neW")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map { $0.name }, ["New York", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["Canada","USA"])
    }

    func testSearchCityEmptyText() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1]
        viewModel.showFavoritesOnly = false
        await viewModel.testable.getSearchTask?.value
        // When
        viewModel.searchCity(text: "")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map{ $0.name }, ["Los Angeles", "New York", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["USA", "Canada", "USA"])
    }

    func testSearchCityNoMatches() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1]
        viewModel.showFavoritesOnly = false
        await viewModel.testable.getSearchTask?.value

        // When
        viewModel.searchCity(text: "Sydney")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.count, 0)
    }

    func testSearchCityFavoritesWithMatches() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getFavoriteCities()?.value
        viewModel.showFavoritesOnly = true
        await viewModel.testable.getSearchTask?.value
        // When
        viewModel.searchCity(text: "New")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map { $0.name }, ["New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["Canada"])
    }

    func testSearchCityFavoritesWithMatchesIsCaseSensitive() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getFavoriteCities()?.value
        viewModel.showFavoritesOnly = true
        await viewModel.testable.getSearchTask?.value
        // When
        viewModel.searchCity(text: "neW")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map { $0.name }, ["New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["Canada"])
    }

    func testSearchCityFavoritesEmptyText() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1,3]
        try await viewModel.getFavoriteCities()?.value
        viewModel.showFavoritesOnly = true
        await viewModel.testable.getSearchTask?.value
        // When
        viewModel.searchCity(text: "")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.map{ $0.name }, ["Los Angeles", "New York"])
        XCTAssertEqual(viewModel.filteredCities.map{ $0.country }, ["USA", "Canada"])
    }

    func testSearchCityFavoritesNoMatches() async throws {
        // Given
        await initialTasks()
        let cities = [
            City(name: "New York",id: 1,country: "Canada",coordinates: Coordinates(latitude: 43.6510,longitude: -79.3470)),
            City(name: "New York", id: 2, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 3, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockCityApiService.cities = cities
        try await viewModel.getCities()?.value
        mockCityApiService.favoriteCities = [1]
        try await viewModel.getFavoriteCities()?.value
        viewModel.showFavoritesOnly = true
        await viewModel.testable.getSearchTask?.value

        // When
        viewModel.searchCity(text: "Los Angeles")
        await viewModel.testable.getSearchTask?.value

        // Then
        XCTAssertEqual(viewModel.filteredCities.count, 0)
    }
}
