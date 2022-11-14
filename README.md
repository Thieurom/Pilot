# 👨‍✈️ Pilot

[![CI](https://github.com/Thieurom/Pilot/actions/workflows/ci.yml/badge.svg)](https://github.com/Thieurom/Pilot/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-red)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-red)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-red)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-red)

Pilot is a very simple HTTP network layer written in Swift, built on top of Apple's [Combine](https://developer.apple.com/documentation/combine) framework. It's inspired by [Moya](https://github.com/Moya/Moya) and [Alamofire](https://github.com/Alamofire/Alamofire).

## Basic Usage

Start by creating your routes to the remote resources:
```swift
enum FlightRoute {

    case getFlights
    case getFlight(String)
    case addFlight
    case updateFlight
    case deleteFlight
}
```

Extend your routes conforming to the `Route` protocol:
```swift
extension FlightRoute: Route {

    var baseURL: URL { URL(string: "/flights")! }

    var path: String {
        switch self {
        case let .getFlight(id): return "/\(id)"
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
        case .getFlights: return ["size": "20"]
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
```

Let the Pilot fly your routes:
```swift
let network = Pilot<FlightRoute>()
network.request(.getFlights)
    .sink(receiveCompletion: { completion in
        // ...
    }, receiveValue: { response in
        // ...
    })
    .store(in: &cancellables)
```
The returned `response` object is the type of `Response` that contains information about `HTTPURLResponse` and `Data` if available.

To get the `Decodable` model out of the response indicates the type of model and optionally your custom `JSONDecoder`:
```swift
network.request(.getFlights, for: [Flight].self, decoder: jsonDecoder)
    .sink(receiveCompletion: { completion in
        // ...
    }, receiveValue: { flights in
        // ...
    })
    .store(in: &cancellables)
```

## Installation

You can add Pilot to an Xcode project as a package dependency.
> https://github.com/Thieurom/Pilot

If you want to use Pilot in a [SwiftPM](https://www.swift.org/package-manager/) project, it's as simple as adding it to a dependencies clause in your Package.swift:
```
dependencies: [
  .package(url: "https://github.com/Thieurom/Pilot", from: "0.1.0")
]
```
