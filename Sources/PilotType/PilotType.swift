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
    func request<T: Decodable>(_ route: R, target: T.Type, decoder: JSONDecoder) -> AnyPublisher<T, PilotError>
    func request<T: Decodable, E: DesignatedError>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) -> AnyPublisher<T, PilotError>
}
