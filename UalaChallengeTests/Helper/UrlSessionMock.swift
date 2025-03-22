//
//  UrlSessionMock.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//

import Foundation
@testable import UalaChallenge

class URLSessionMock: URLSessionProtocol {
    private let data: Data?
    private let response: URLResponse?
    private let error: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}
