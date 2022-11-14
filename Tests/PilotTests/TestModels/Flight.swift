//
//  Flight.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation

struct Flight: Decodable {

    let code: String
    let departure: String
    let arrival: String
    let departureTime: Date
    let estimatedArrivalTime: Date
}
