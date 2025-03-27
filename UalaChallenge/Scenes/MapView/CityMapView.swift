//
//  CityMapView.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 23/3/25.
//

import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    @State private var cameraPosition: MapCameraPosition
    @State private var showWebView = false

    init(city: City) {
        self.city = city
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: city.coordinates.latitude,
                        longitude: city.coordinates.longitude
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.05,
                        longitudeDelta: 0.05
                    )
                )
            )
        )
    }

    var body: some View {
        Map(position: $cameraPosition) {
            Annotation(
                "City",
                coordinate: CLLocationCoordinate2D(
                    latitude: city.coordinates.latitude,
                    longitude: city.coordinates.longitude
                )
            ) {
                Button(action: {
                    showWebView.toggle()
                }) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(city.name)
                            .fixedSize()
                    }
                }.sheet(isPresented: $showWebView) {
                    WebView(url: URL(string: "https://www.google.com/search?q=\(city.name)+\(city.country)")!)
                }
            }
        }.onAppear {
            updateCameraPosition()
        }
        .onChange(of: city) {
            updateCameraPosition()
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("CityMapView")
    }
    
    private func updateCameraPosition() {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: city.coordinates.latitude,
                    longitude: city.coordinates.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }
}
