//
//  Coordinates.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import Foundation

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}
