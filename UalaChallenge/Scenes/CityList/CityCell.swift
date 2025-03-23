//
//  CityCell.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//
import SwiftUI

struct CityCell: View {
    let city: City
    @ObservedObject var viewModel: CityListViewModelImpl

    var body: some View {
        VStack(alignment: .leading) {
             HStack {
                 Text(city.name)
                     .font(.headline)
                 Spacer()
                 Text(city.country)
                     .font(.subheadline)
                     .foregroundColor(.secondary)
                 FavoriteButton(city: city, viewModel: viewModel)
             }
             HStack {
                 Text("Lon: \(city.coordinates.latitude), Lat: \(city.coordinates.longitude)")
                     .font(.caption)
                     .foregroundColor(.gray)
                 Spacer()
             }
         }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
