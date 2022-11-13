//
//  FlightRoute.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation
@testable import Pilot

enum FlightRoute {

    case getFlights
    case getFlight(String)
    case addFlight
    case updateFlight
    case deleteFlight
}

extension FlightRoute: Route {

    var baseURL: URL { URL(string: "/flights")! }

    var path: String {
        switch self {
        case let .getFlight(id): return "/\(id)"
        default: return ""
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        case .getFlights, .getFlight: return .get
        case .addFlight: return .post
        case .updateFlight: return .put
        case .deleteFlight: return .delete
        }
    }

    var httpHeaders: HttpHeaders { [:] }
    var parameters: Parameters? {
        switch self {
        case .getFlights: return ["size": "20"]
        default: return nil
        }
    }

    var parameterEncoding: ParameterEncoding? {
        switch self {
        case .getFlights: return .url
        case .addFlight, .updateFlight: return .json
        default: return nil
        }
    }
}
