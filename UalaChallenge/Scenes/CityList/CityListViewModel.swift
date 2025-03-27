//
//  CityListViewModel.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

import Combine
import CoreData
import Foundation

@MainActor
protocol CityListViewModel: ObservableObject {
    var isLoading: Bool { get }
    var selectedCity: City? { get }
    var filteredCities: [City] { get }
    var errorMessage: String? { get }
    var showFavoritesOnly: Bool { get  }
    @discardableResult
    func getCities() async throws -> Task<Void, Never>?
    @discardableResult
    func getFavoriteCities() async throws -> Task<Void, Never>?
    @discardableResult
    func addToFavorite(city: City) async throws -> Task<Void, Never>?
    @discardableResult
    func removeFromFavorite(city: City) async throws -> Task<Void, Never>?
    func isFavorite(city: City) async throws -> Task<Bool, Never>?
    func searchCity(text: String)
    func setSelectedCity(_ city: City?)
    func toggleShowFavoritesOnly()
}

final class CityListViewModelImpl: ObservableObject, CityListViewModel, TestableNamespaceConvertible {

    // public vars
    @Published
    private(set) var isLoading: Bool = true
    @Published
    private(set) var selectedCity: City?
    @Published
    private(set) var filteredCities: [City] = []
    @Published
    private(set) var errorMessage: String?
    @Published
    private(set) var showFavoritesOnly: Bool = false

    //private variables
    private var cities: [City] = []
    fileprivate var favoriteCities: [City] = []
    private var cityApiService: CityApiService
    private var lastSearchText: String = ""

    //Tasks
    fileprivate var getCitiesTask: Task<Void, Never>?
    fileprivate var getFavoriteCitiesTask: Task<Void, Never>?
    fileprivate var initialTask: Task<Void, Never>?
    fileprivate var addToFavoriteTask: Task<Void, Never>?
    fileprivate var removeFromFavoriteTask: Task<Void, Never>?
    fileprivate var isFavoriteTask: Task<Bool, Never>?
    fileprivate var searchTask: Task<Void, Never>?

    init(
        cityApiService: CityApiService = CityApiServiceImpl(
            context: PersistenceController.shared.container.viewContext
        )
    ) {
        self.cityApiService = cityApiService
        initialTask = Task {
            do {
                try await self.getCities()
                try await self.getFavoriteCities()
            } catch {

            }
        }
    }

    //MARK: funciones internas

    private func sort(cities: [City]) -> [City] {
        return cities.sorted {
            if $0.name == $1.name {
                return $0.country < $1.country
            }
            return $0.name < $1.name
        }
    }

    //MARK:  Protocol Functions
    @discardableResult
    func getCities() async throws -> Task<Void, Never>? {
        getCitiesTask?.cancel()
        isLoading = true
        let task = Task { [weak self] in
            do {
                guard !(self?.getCitiesTask?.isCancelled ?? true) else {
                    self?.isLoading = false
                    return
                }
                let unsortedCities = try await self?.cityApiService.fetchCities()
                guard !(self?.getCitiesTask?.isCancelled ?? true) else {
                    self?.isLoading = false
                    return
                }
                self?.cities = self?.sort(cities: unsortedCities ?? []) ?? []
                self?.filteredCities = self?.cities ?? []
                self?.isLoading = false
            } catch {
                guard !(self?.getCitiesTask?.isCancelled ?? true) else {
                    self?.isLoading = false
                    return
                }
                self?.cities = []
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
        getCitiesTask = task
        return task
    }

    @discardableResult
    func getFavoriteCities() async throws -> Task<Void, Never>? {
        getFavoriteCitiesTask?.cancel()
        let task = Task { [weak self] in
            do {
                let favoriteCities = try await self?.cityApiService.fetchFavoriteCities() ?? []
                guard !(self?.getFavoriteCitiesTask?.isCancelled ?? true) else { return }
                self?.favoriteCities = self?.sort(cities: favoriteCities) ?? []
            } catch {
                guard !(self?.getFavoriteCitiesTask?.isCancelled ?? true) else { return }
                self?.favoriteCities = []
                self?.errorMessage = error.localizedDescription
            }
        }
        getFavoriteCitiesTask = task
        return task
    }

    @discardableResult
    func addToFavorite(city: City) async throws -> Task<Void, Never>? {
        addToFavoriteTask?.cancel()
        let task = Task {[weak self] in
            do {
                try await self?.cityApiService.addCityToFavorites(city)
                try await self?.getFavoriteCities()
            } catch {
                guard !(self?.addToFavoriteTask?.isCancelled ?? true) else { return }
                self?.errorMessage = error.localizedDescription
            }
        }

        addToFavoriteTask = task
        return task
    }

    @discardableResult
    func removeFromFavorite(city: City) async throws -> Task<Void, Never>? {
        removeFromFavoriteTask?.cancel()
        let task = Task { [weak self] in
            do {
                try await self?.cityApiService.removeCityFromFavorites(city)
                try await self?.getFavoriteCities()
                self?.searchCity(text: self?.lastSearchText ?? "")
            } catch {
                guard !(self?.removeFromFavoriteTask?.isCancelled ?? true) else { return }
                self?.errorMessage = error.localizedDescription
            }
        }

        removeFromFavoriteTask = task
        return task
    }


    func isFavorite(city: City) async throws -> Task<Bool, Never>? {
        isFavoriteTask?.cancel()
        let task =  Task<Bool, Never> { [weak self] in
            do {
                let isFavorite =  try await self?.cityApiService.isCityInFavorites(city)
                return isFavorite ?? false
            } catch {
                guard !(self?.isFavoriteTask?.isCancelled ?? true) else { return false }
                self?.errorMessage = error.localizedDescription
                return false
            }
        }

        isFavoriteTask = task
        return task
    }

    func searchCity(text: String) {
        searchTask?.cancel()
        lastSearchText = text
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !(self?.searchTask?.isCancelled ?? true) else { return }
            await MainActor.run {
                guard let self = self else { return }
                let sourceCities = self.showFavoritesOnly ? self.favoriteCities : self.cities
                self.filteredCities = text.isEmpty ? sourceCities : sourceCities.filter { city in
                    city.name.range(of: text, options: .caseInsensitive) != nil
                }
            }
        }
    }
    func setSelectedCity(_ city: City?) {
        selectedCity = city
    }

    func toggleShowFavoritesOnly() {
        showFavoritesOnly.toggle()
        searchCity(text: lastSearchText)
    }
}

// MARK: - TestableNamespace

#if DEBUG

extension TestableNamespace where Base: CityListViewModelImpl {

    nonisolated var initialTask: Task<Void, Never>? {
        MainActor.assumeIsolated {
            return base.initialTask
        }
    }

    nonisolated var getCitiesTask: Task<Void, Never>? {
        MainActor.assumeIsolated {
            return base.getCitiesTask
        }
    }

    nonisolated var getFavoriteCitiesTask: Task<Void, Never>? {
        MainActor.assumeIsolated {
            return base.getFavoriteCitiesTask
        }
    }

    nonisolated var getSearchTask: Task<Void, Never>? {
        MainActor.assumeIsolated {
            return base.searchTask
        }
    }

    nonisolated  var  favoriteCities: [City] {
        MainActor.assumeIsolated {
            return base.favoriteCities
        }
    }
}

#endif

