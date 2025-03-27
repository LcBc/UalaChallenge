//
//  CityCell.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//
import SwiftUI

struct CityCell<ViewModel>: View where ViewModel: CityListViewModel {
    let city: City
    @ObservedObject var viewModel: ViewModel
    @State private var showWebView = false
    
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
                Button(action: {
                    showWebView.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }.sheet(isPresented: $showWebView) {
                    WebView(url: URL(string: "https://www.google.com/search?q=\(city.name)+\(city.country)")!)
                }
            }
        }
    }
}
