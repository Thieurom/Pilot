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
    case deleteFlight(String)
}

extension FlightRoute: Route {

    var baseURL: URL { URL(string: "/api/flights")! }

    var path: String {
        switch self {
        case let .getFlight(id),
            let .deleteFlight(id): return "/\(id)"
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
        case .getFlights: return ["limit": "20"]
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
