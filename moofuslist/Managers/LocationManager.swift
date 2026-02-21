//
//  LocationManager.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import Combine
import CoreLocation
import FactoryKit
import os
import SwiftUI

protocol LocationUpdateProtocol: Sendable {
  var accuracyLimited: Bool { get }
  var authorizationDenied: Bool { get }
  var authorizationDeniedGlobally: Bool { get }
  var authorizationRequestInProgress: Bool { get }
  var authorizationRestricted: Bool { get }
  var insufficientlyInUse: Bool { get }
  var location: CLLocation? { get }
  var locationUnavailable: Bool { get }
  var serviceSessionRequired: Bool { get }
  var stationary: Bool { get }
}

extension CLLocationUpdate: LocationUpdateProtocol {}

protocol LocationUpdateStream: AsyncSequence where Element: LocationUpdateProtocol { }

extension CLLocationUpdate.Updates: LocationUpdateStream { }

actor LocationManager {
  @Injected(\.liveUpdates) var liveUpdates: any LocationUpdateStream

  private let continuation: AsyncStream<Message>.Continuation
  private(set) var count = 0
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "LocationManager")
  private var maxCount = Int.max
  let stream: AsyncStream<Message>
  private var task: Task<Void, Never>?

  private(set) var started = false {
    didSet {
      reset()
      if started {
        processUpdates(updates: liveUpdates )
      }
    }
  }

  init() {
    (stream, continuation) = AsyncStream<Message>.makeStream()
  }
}

// MARK: - Private Methods
extension LocationManager {
  private func reset() {
    count = 0
    task?.cancel()
    task = nil
  }

  // swiftlint:disable cyclomatic_complexity function_body_length
  private func processUpdates<S: LocationUpdateStream>(updates: S) {
    task = Task {
      logger.info("LocationManager processUpdates started")
      do {
        for try await update in updates {
          if Task.isCancelled { break }
          if !started { break }
          if let location = await update.location {
            continuation.yield(.location(location))
            count += 1
            logger.info("count=\(self.count) location=\(location)")
            if count >= maxCount {
              break
            }
          }
          if await update.accuracyLimited {
            continuation.yield(.info(.accuracyLimited))
            logger.info("""
                        Location accuracyLimited: Moofuslist can't access your precise location, \
                        using approximate location
                        """)
          }
          if await update.authorizationDeniedGlobally {
            continuation.yield(.error(.authorizationDeniedGlobally))
            logger.info("Location authorizationDeniedGlobally")
            break
          }
          if await update.authorizationDenied {
            continuation.yield(.error(.authorizationDenied))
            logger.info("Location authorizationDenied")
            break
          }
          if await update.authorizationRequestInProgress {
            continuation.yield(.info(.authorizationRequestInProgress))
            logger.info("Location authorizationRequestInProgress")
            continue
          }
          if await update.authorizationRestricted {
            continuation.yield(.error(.authorizationRestricted))
            logger.info("Location authorizationRestricted, maybe disable Parental Controls?")
            break
          }
          if await update.insufficientlyInUse {
            continuation.yield(.info(.insufficientlyInUse))
            logger.info("Location insufficientlyInUse")
          }
          if await update.locationUnavailable {
            continuation.yield(.error(.locationUnavailable))
            logger.info("Location locationUnavailable")
            break
          }
          if await update.serviceSessionRequired {
            continuation.yield(.info(.serviceSessionRequired))
            logger.info("Location serviceSessionRequired")
          }
          if await update.stationary {
            continuation.yield(.info(.stationary))
            logger.info("Location stationary")
          }
        }
      } catch {
        print("error=\(error)")
        assertionFailure()
        continuation.yield(.error(.unknown))
        return
      }
      started = false
      logger.info("LocationManager processUpdates finished")
    }
  }
  // swiftlint:enable cyclomatic_complexity function_body_length
}

// MARK: - Error Enum
extension LocationManager {
  enum Error: LocalizedError {
    case authorizationDenied
    case authorizationDeniedGlobally
    case authorizationRestricted
    case locationUnavailable
    case unknown

    var failureReason: String? {
      switch self {
      case .authorizationDenied:
        """
        User denied location permissions for Moofuslist or location services are turned off or \
        device is in Airplane mode
        """
      case .authorizationDeniedGlobally: "Location Services are disabled for this device."
      case .authorizationRestricted:
        "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .locationUnavailable: "Location Unabailable"
      case .unknown: "Unknown Error"
      }
    }

    var errorDescription: String? {
      "Can't get location."
    }

    var recoverySuggestion: String? {
      switch self {
      case .authorizationDenied: "Please authorize Moofuslist to access Location Services"
      case .authorizationDeniedGlobally:
        "Please enable Location Services by going to Settings -> Privacy & Security"
      case .authorizationRestricted: "Maybe disable Parental Controls?"
      case .locationUnavailable: "Location Unabailable"
      case .unknown: "Unknown Error"
      }
    }
  }

  enum Info: String {
    case accuracyLimited
    case authorizationRequestInProgress
    case insufficientlyInUse
    case serviceSessionRequired
    case stationary
  }

  enum Message {
    case error(Error)
    case info(Info)
    case location(CLLocation)
  }
}

// MARK: - Public Methods
extension LocationManager {
  func start(maxCount: Int = Int.max) {
    self.maxCount = maxCount
    started = true
  }
}

#if DEBUG
// MARK: - Test Hooks
extension LocationManager {
  /// Test hooks to access actor state for testing purposes
  nonisolated func testHooks() -> TestHooks {
    TestHooks(locationManager: self)
  }

  struct TestHooks {
    let locationManager: LocationManager

    var stream: AsyncStream<LocationManager.Message> {
      locationManager.stream
    }

    func start(maxCount: Int = Int.max) async {
      await locationManager.start(maxCount: maxCount)
    }
  }
}

// swiftlint:disable comment_spacing
//struct LocationManagerView: View {
//  @State private var test = false
//
//  var body: some View {
//
//    VStack {
//      GroupBox(label: Label("Settings", systemImage: "gear")) {
//        Text("Option 1")
//        Toggle("Location Services", isOn: $locationManager.started)
//        Toggle("test", isOn: $test)
//      }
//      .font(.headline)
//      .padding()
//    }
//    .alert(isPresented: $locationManager.haveError, error: locationManager.error) { _ in
//      Button("OK") {
//        locationManager.stop()
//      }
//    } message: { error in
//      Text(error.recoverySuggestion ?? "Try again later.")
//    }
//  }
//}
//
//#Preview {
//  LocationManagerView()
//}
//
// swiftlint:enable comment_spacing

#endif // DEBUG
