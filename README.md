# 👨‍✈️ Pilot

[![CI](https://github.com/Thieurom/Pilot/actions/workflows/ci.yml/badge.svg)](https://github.com/Thieurom/Pilot/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5.5_|_5.6_|_5.7-red)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-red)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_|_iOS_|_tvOS_|_watchOS-red)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-red)

Pilot is a very simple HTTP network layer written in Swift, supports both modern concurency in Swift with `async/await` as well as [Combine](https://developer.apple.com/documentation/combine) framework. It's inspired by [Moya](https://github.com/Moya/Moya) and [Alamofire](https://github.com/Alamofire/Alamofire).

## Basic Usage

- Start by creating your routes to the API:
  ```swift
  enum FlightRoute {

      case getFlights
      case getFlight(String)
      case addFlight
      case updateFlight
      case deleteFlight(String)
  }
  ```

- Extend your routes conforming to the `Route` protocol:
  ```swift
  extension FlightRoute: Route {

      var baseURL: URL { URL(string: "/api/flights")! }
  
      var path: String {
          switch self {
          case let .getFlight(id),
              let .deleteFlight(id): return "/\(id)"
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
  
      var httpHeaders: HttpHeaders { .empty }
  
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
  ```

- Let the Pilot fly your routes:
  ```swift
  let network = Pilot<FlightRoute>()
  ```
  ```swift
  // Inside an asynchronous function
  do {
      let response = try await network.request(.getFlights)
      // do something useful
  } catch {
      // handle error
  }
  ```

  <details>
  <summary><h4>With Combine</h4></summary>

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
  </details>

### Decoding JSON response

To get the `Decodable` model out of the response indicates the type of model and optionally provides your custom `JSONDecoder` (Pilot uses the default one, which means with all default decoding strategies):
```swift
do {
    let flights = try await network.request(.getFlights, target: [Flight].self, decoder: jsonDecoder)
    // do something useful
} catch {
    // handle error
}
```

<details>
<summary><h4>With Combine</h4></summary>

```swift
network.request(.getFlights, target: [Flight].self, decoder: jsonDecoder)
    .sink(receiveCompletion: { completion in
        // ...
    }, receiveValue: { flights in
        // ...
    })
    .store(in: &cancellables)
```
</details>

### Decoding JSON error

If the API you're consuming supports JSON error, it can be returned as the associated value of `PilotError.designated`:
```swift
do {
    let flights = try await network.request(.getFlights, target: [Flight].self, failure: FlightApiError.self decoder: jsonDecoder)
    // do something useful
} catch {
    if case let .designated(apiError) = error as? PilotError {
        // handle your designated `FlightApiError`
    }
}
```
Just make sure your `FlightApiError` conform to `DesignatedError` (which is a typealias of `Error & Decodable`)

<details>
<summary><h4>With Combine</h4></summary>

```swift
network.request(.getFlights, target: [Flight].self, failure: FlightApiError.self, decoder: jsonDecoder)
    .sink(receiveCompletion: { completion in
        if case .failure(error) = completion, case let .designated(apiError) = error {
            // The `apiError` is type of `FlightApiError`
        }
    }, receiveValue: { flights in
        // ...
    })
    .store(in: &cancellables)
```
</details>

## Installation

You can add Pilot to an Xcode project as a package dependency.
> https://github.com/Thieurom/Pilot

If you want to use Pilot in a [SwiftPM](https://www.swift.org/package-manager/) project, it's as simple as adding it to a dependencies clause in your `Package.swift`:
```
dependencies: [
  .package(url: "https://github.com/Thieurom/Pilot", from: "0.5.0")
]
```
