//
//  MockingURLProtocol.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 13/11/2022.
//

import Foundation

class MockingURLProtocol: URLProtocol {

    enum Error: Swift.Error, LocalizedError, CustomDebugStringConvertible {

        case missingMock

        var errorDescription: String? { debugDescription }

        var debugDescription: String {
            switch self {
            case .missingMock: return "Missing mock"
            }
        }
    }

    static var mock: Mock?
    private var dataTask: URLSessionDataTask?

    static func urlSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockingURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let mock = Self.mock else {
            client?.urlProtocol(self, didFailWithError: Error.missingMock)
            return
        }

        guard mock.error == nil else {
            client?.urlProtocol(self, didFailWithError: mock.error!)
            return
        }

        if let data = mock.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = mock.httpResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        dataTask?.cancel()
    }
}

// MARK: - Mock+httpResponse

extension Mock {

    var httpResponse: HTTPURLResponse? {
        .init(
            url: URL(string: "/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}
