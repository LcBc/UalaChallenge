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
            CitiesListView(viewModel: CityListViewModelImpl())
        }
    }
}
