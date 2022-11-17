//
//  Response.swift
//  Pilot
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Foundation

public struct Response {

    public let httpResponse: HTTPURLResponse?
    public let data: Data?

    public init(httpResponse: HTTPURLResponse?, data: Data?) {
        self.httpResponse = httpResponse
        self.data = data
    }
}
