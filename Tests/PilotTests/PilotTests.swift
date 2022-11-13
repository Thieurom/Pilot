//
//  PilotTests.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Combine
import XCTest
@testable import Pilot

final class PilotTests: XCTestCase {

    var network: Pilot<FlightRoute>!
    private var mockURLSession: URLSession!

    private var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return jsonDecoder
    }()

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        mockURLSession = MockingURLProtocol.urlSession()
        network = Pilot(session: mockURLSession)
        cancellables = []
    }

    override func tearDown() {
        mockURLSession = nil
        network = nil
        super.tearDown()
    }
}

extension PilotTests {

    func testRequestGetFlight_FailWithUnderlyingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")
        MockingURLProtocol.mock = Mock(statusCode: 500, error: URLError(.unknown), data: nil)

        network.request(.getFlight("ABC123"))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    expectedError = error
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        guard case .underlying = expectedError else {
            XCTFail("Should return an underlying error!")
            return
        }
    }

    func testRequestGetFlight_FailWithDecodingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "code": "ABC123",
            "departure": "DEP",
            "arrival": "ARV",
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"), for: Flight.self, decoder: jsonDecoder)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    expectedError = error
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        guard case .decoding = expectedError else {
            XCTFail("Should return decoding error!")
            return
        }
    }

    func testRequestGetFlight_SuccessWithResponse() {
        var expectedResponse: Response!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "code": "ABC123",
            "departure": "DEP",
            "arrival": "ARV",
            "departure_time": 1597169495,
            "estimated_arrival_time": 1597176695
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"))
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should return successfully!")
                    return
                }
            }, receiveValue: {
                expectedResponse = $0
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        XCTAssertNotNil(expectedResponse)
    }

    func testRequestGetFlight_SuccessWithModel() {
        var expectedFlight: Flight!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "code": "ABC123",
            "departure": "DEP",
            "arrival": "ARV",
            "departure_time": 1597169495,
            "estimated_arrival_time": 1597176695
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"), for: Flight.self, decoder: jsonDecoder)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should return successfully!")
                    return
                }
            }, receiveValue: {
                expectedFlight = $0
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        XCTAssertNotNil(expectedFlight)
    }

    func testRequestGetFlights_SuccessWithModels() {
        var expectedFlights = [Flight]()
        let expectation = expectation(description: "getFlights")

        let json = """
        [
            {
                "code": "ABC123",
                "departure": "DEP",
                "arrival": "ARV",
                "departure_time": 1597169495,
                "estimated_arrival_time": 1597176695
            }
        ]
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlights, for: [Flight].self, decoder: jsonDecoder)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should return successfully!")
                    return
                }
            }, receiveValue: {
                expectedFlights = $0
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        XCTAssertFalse(expectedFlights.isEmpty)
    }
}
