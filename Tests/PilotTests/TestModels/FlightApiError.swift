//
//  FlightApiError.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 14/11/2022.
//

import Foundation
@testable import Pilot

struct FlightApiError: DesignatedError {

    struct Detail: Decodable {

        let code: Int
        let description: String
    }

    let error: Detail
}
