//
//  PilotError.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation

public typealias DesignatedError = Error & Decodable

public enum PilotError: Error {

    case decoding
    case designated(DesignatedError)
    case underlying(Error)
}

extension PilotError: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .decoding: return "Failed to decode object"
        case let .designated(error): return error.localizedDescription
        case let .underlying(error): return error.localizedDescription
        }
    }
}

extension PilotError: LocalizedError {

    public var errorDescription: String? { debugDescription }
}
