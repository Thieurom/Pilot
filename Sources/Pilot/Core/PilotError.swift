//
//  PilotError.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation

public enum PilotError: Error {

    case decoding
    case underlying(Error)
}

extension PilotError: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .decoding: return "Failed to decode object"
        case let .underlying(error): return error.localizedDescription
        }
    }
}

extension PilotError: LocalizedError {

    public var errorDescription: String? { debugDescription }
}
