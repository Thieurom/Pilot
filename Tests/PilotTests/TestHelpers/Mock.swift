//
//  Mock.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 13/11/2022.
//

import Foundation

struct Mock {

    let statusCode: Int
    let error: Error?
    let data: Data?

    init(statusCode: Int, error: Error?, data: Data?) {
        self.statusCode = statusCode
        self.error = error
        self.data = data
    }

    init(statusCode: Int, error: Error?, json: String?) {
        self.statusCode = statusCode
        self.error = error
        self.data = json.flatMap { $0.data(using: .utf8) }
    }
}
