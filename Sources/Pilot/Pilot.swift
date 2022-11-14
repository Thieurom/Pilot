//
//  Pilot.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Combine
import Foundation

public struct Pilot<R: Route> {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request(_ route: R) -> AnyPublisher<Response, PilotError> {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: Pilot.processResponse)
            .map {
                Response(
                    httpResponse: $1 as? HTTPURLResponse,
                    data: $0
                )
            }
            .mapError { .underlying($0) }
            .handleEvents(receiveCompletion: {
                if case let .failure(error) = $0 {
                    Self.debugLog(error: error)
                }
            })
            .eraseToAnyPublisher()
    }

    public func request<A: Decodable>(_ route: R, for type: A.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<A, PilotError> {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: Pilot.processResponse)
            .map(\.data)
            .decode(type: A.self, decoder: decoder)
            .mapError { error -> PilotError in
                if error is DecodingError {
                    return .decoding
                }

                return .underlying(error)
            }
            .handleEvents(receiveCompletion: {
                if case let .failure(error) = $0 {
                    Self.debugLog(error: error)
                }
            })
            .eraseToAnyPublisher()
    }
}

extension Pilot {

    private static func processResponse(data: Data, response: URLResponse) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        let codeString = statusCode != nil ? "\(statusCode!) " : ""
        debugLog(info: "Response: \n\(codeString)\(String(decoding: data, as: UTF8.self))")
    }
}

extension Pilot {

    private static func debugLog(info: String) {
        #if DEBUG
        print("[Pilot][INFO] \(info)")
        #endif
    }

    private static func debugLog(error: Error) {
        #if DEBUG
        print("[Pilot][ERROR] \(error.localizedDescription)")
        #endif
    }
}
