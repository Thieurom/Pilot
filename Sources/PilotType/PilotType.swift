//
//  PilotType.swift
//  Pilot
//
//  Created by Doan Thieu on 17/11/2022.
//

import Combine
import Foundation

public protocol PilotType {

    associatedtype R: Route

    func request(_ route: R) -> AnyPublisher<Response, PilotError>
    func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) -> AnyPublisher<T, PilotError> where T: Decodable
    func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) -> AnyPublisher<T, PilotError> where T: Decodable, E: DesignatedError
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func request(_ route: R) async throws -> Response
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) async throws -> T where T: Decodable
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) async throws -> T where T: Decodable, E: DesignatedError
}
