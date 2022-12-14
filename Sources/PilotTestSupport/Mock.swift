//
//  Mock.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 13/11/2022.
//

import Foundation

public struct Mock {

    public let statusCode: Int
    public let error: Error?
    public let data: Data?

    public init(statusCode: Int, error: Error?, data: Data?) {
        self.statusCode = statusCode
        self.error = error
        self.data = data
    }

    public init(statusCode: Int, error: Error?, json: String?) {
        self.statusCode = statusCode
        self.error = error
        self.data = json.flatMap { $0.data(using: .utf8) }
    }
}
