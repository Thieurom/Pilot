//
//  PilotTests.swift
//  PilotTests
//
//  Created by Doan Le Thieu on 12/11/2022.
//

import Combine
import PilotType
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

    func testRequestResponse_FailWithUnderlyingError() {
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

    func testRequestResponse_SuccessWithResponse() {
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
}

extension PilotTests {

    func testRequestTarget_FailWithUnderlyingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")
        MockingURLProtocol.mock = Mock(statusCode: 500, error: URLError(.unknown), data: nil)

        network.request(.getFlight("ABC123"), target: [Flight].self, decoder: jsonDecoder)
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

    func testRequestTarget_APIReturnSuccess_FailWithDecodingError() {
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

        network.request(.getFlight("ABC123"), target: Flight.self, decoder: jsonDecoder)
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

    func testRequestGetFlight_APIReturnSuccess_SuccessWithModel() {
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

        network.request(.getFlight("ABC123"), target: Flight.self, decoder: jsonDecoder)
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
}

extension PilotTests {

    func testRequestTargetFailure_FailWithUnderlyingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")
        MockingURLProtocol.mock = Mock(statusCode: 500, error: URLError(.unknown), data: nil)

        network.request(.getFlight("ABC123"), target: [Flight].self, failure: FlightApiError.self, decoder: jsonDecoder)
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

    func testRequestTargetFailure_APIReturnFailure_FailWithDecodingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "error": {
                "code": 404
            }
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"), target: Flight.self, failure: FlightApiError.self, decoder: jsonDecoder)
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

    func testRequestTargetFailure_APIReturnFailure_FailWithDesignatedError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "error": {
                "code": 404,
                "description": "Invalid flight id."
            }
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"), target: Flight.self, failure: FlightApiError.self, decoder: jsonDecoder)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    expectedError = error
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        guard case .designated = expectedError else {
            XCTFail("Should return designated error!")
            return
        }
    }

    func testRequestTargetFailure_APIReturnSuccess_FailWithDecodingError() {
        var expectedError: PilotError!
        let expectation = expectation(description: "getFlight")

        let json = """
        {
            "code": "ABC123",
            "departure": "DEP",
            "arrival": "ARV"
        }
        """

        MockingURLProtocol.mock = Mock(statusCode: 200, error: nil, json: json)

        network.request(.getFlight("ABC123"), target: Flight.self, failure: FlightApiError.self, decoder: jsonDecoder)
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

    func testRequestTargetFailure_APIReturnSuccess_SuccessWithModel() {
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

        network.request(.getFlight("ABC123"), target: Flight.self, failure: FlightApiError.self, decoder: jsonDecoder)
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
}
