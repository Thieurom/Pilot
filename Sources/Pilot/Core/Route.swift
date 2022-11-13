//
//  Route.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation

public protocol Route {

    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var httpHeaders: HttpHeaders { get }
    var parameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding? { get }
}

extension Route {

    public var url: URL {
        guard !path.isEmpty else {
            return baseURL
        }

        return baseURL.appendingPathComponent(path)
    }
}
