//
//  URLSessionProtocol.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        return try await self.data(from: url, delegate: nil) // Use the instance method directly
    }
}
