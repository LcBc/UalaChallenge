//
//  City.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import Foundation

struct City: Codable, Equatable {

    let name: String
    let id: Int
    let country: String
    let coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case name
        case id = "_id"
        case country
        case coordinates = "coord"
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}
