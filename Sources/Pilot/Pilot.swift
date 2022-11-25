//
//  Pilot.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Combine
import Foundation
import PilotType

public struct Pilot<R: Route>: PilotType {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
}

extension Pilot {

    public func request(_ route: R) -> AnyPublisher<Response, PilotError> {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: processResponse)
            .map {
                Response(
                    httpResponse: $1 as? HTTPURLResponse,
                    data: $0
                )
            }
            .mapError(processError)
            .handleEvents(receiveCompletion: {
                if case let .failure(error) = $0 {
                    Self.debugLog(error: error)
                }
            })
            .eraseToAnyPublisher()
    }

    public func request<T: Decodable>(_ route: R, target: T.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<T, PilotError> {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: processResponse)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .mapError(processError)
            .handleEvents(receiveCompletion: {
                if case let .failure(error) = $0 {
                    Self.debugLog(error: error)
                }
            })
            .eraseToAnyPublisher()
    }

    public func request<T: Decodable, E: DesignatedError>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<T, PilotError> {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: processResponse)
            .tryMap { data, _ in
                return try decodeApi(target: T.self, failure: E.self, from: data, decoder: decoder)
            }
            .mapError(processError)
            .handleEvents(receiveCompletion: {
                if case let .failure(error) = $0 {
                    Self.debugLog(error: error)
                }
            })
            .eraseToAnyPublisher()
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Pilot {

    public func request(_ route: R) async throws -> Response {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        do {
            let (data, response) = try await session.data(for: request)
            return Response(httpResponse: response as? HTTPURLResponse, data: data)
        } catch {
            Self.debugLog(error: error)
            throw processError(error)
        }
    }

    public func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) async throws -> T where T : Decodable {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        do {
            let (data, _) = try await session.data(for: request)
            return try decoder.decode(T.self, from: data)
        } catch {
            Self.debugLog(error: error)
            throw processError(error)
        }
    }

    public func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) async throws -> T where T: Decodable, E: DesignatedError {
        let request = URLRequest(route: route)
        Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")

        do {
            let (data, _) = try await session.data(for: request)
            return try decodeApi(target: T.self, failure: E.self, from: data, decoder: decoder)
        } catch {
            Self.debugLog(error: error)
            throw processError(error)
        }
    }
}

extension Pilot {

    private func processResponse(data: Data, response: URLResponse) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        let codeString = statusCode != nil ? "\(statusCode!) " : ""
        Self.debugLog(info: "Response: \n\(codeString)\(String(decoding: data, as: UTF8.self))")
    }

    private func processError(_ error: Error) -> PilotError {
        switch error {
        case is DecodingError:
            return .decoding
        case let designatedError as DesignatedError:
            return .designated(designatedError)
        default:
            return .underlying(error)
        }
    }

    private func decodeApi<T, E>(target: T.Type, failure: E.Type, from data: Data, decoder: JSONDecoder) throws -> T where T: Decodable, E: DesignatedError {
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            let designatedError: DesignatedError
            do {
                designatedError = try decoder.decode(E.self, from: data)
            } catch {
                throw decodingError
            }

            throw designatedError
        }
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
