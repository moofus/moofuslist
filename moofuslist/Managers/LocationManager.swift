//
//  LocationManager.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import Combine
import CoreLocation
import os
import SwiftUI

extension LocationManager {
  enum Error: LocalizedError {
    case authorizationDenied
    case authorizationDeniedGlobally
    case authorizationRestricted
    case locationUnavailable

    var failureReason: String? {
      switch self {
      case .authorizationDenied:
        "User denied location permissions for Moofuslist or location services are turned off or device is in Airplane mode"
      case .authorizationDeniedGlobally: "Location Services are disabled for this device."
      case .authorizationRestricted: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .locationUnavailable: "Location Unabailable"
      }
    }

    var errorDescription: String? {
      "Can't get location."
    }

    var recoverySuggestion: String? {
      switch self {
      case .authorizationDenied: "Please authorize Moofuslist to access Location Services"
      case .authorizationDeniedGlobally: "Please enable Location Services by going to Settings -> Privacy & Security"
      case .authorizationRestricted: "Maybe disable Parental Controls?"
      case .locationUnavailable: "Location Unabailable"
      }
    }
  }

  enum Message {
    case error(Error)
    case location(CLLocation)
  }
}

actor LocationManager {
  let stream: AsyncStream<Message>

  private let continuation: AsyncStream<Message>.Continuation
  private(set) var count = 0
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "LocationManager")
  private var maxCount = Int.max
  private var task: Task<Void,Never>? = nil

  private(set) var started = false {
    didSet {
      reset()
      if started {
        run()
      }
    }
  }

  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Message.self)
  }
}

// MARK: - Private Methods
extension LocationManager {
  private func reset() {
    count = 0
    task?.cancel()
    task = nil
  }

  private func run() {
    logger.info("LocationManager starting")
    task = Task {
      do {
        let liveUpdates = CLLocationUpdate.liveUpdates()
        for try await update in liveUpdates {
          if Task.isCancelled { print("ljw break"); break }
          if !started { print("ljw started break"); break }
          if let location = update.location {
            continuation.yield(.location(location))
            count += 1
            logger.info("count=\(self.count) location=\(location)")
            if count >= maxCount {
              break
            }
          }
          if update.accuracyLimited {
            logger.info("Location accuracyLimited: Moofuslist can't access your precise location, using approximate location")
          }
          if update.authorizationDeniedGlobally {
            continuation.yield(.error(.authorizationDeniedGlobally))
            logger.info("Location authorizationDeniedGlobally")
            break
          }
          if update.authorizationDenied {
            continuation.yield(.error(.authorizationDenied))
            logger.info("Location authorizationDenied")
            break
          }
          if update.authorizationRequestInProgress {
            logger.info("Location authorizationRequestInProgress")
            continue
          }
          if update.authorizationRestricted {
            continuation.yield(.error(.authorizationRestricted))
            logger.info("Location authorizationDenied, maybe disable Parental Controls?")
            break
          }
          if update.insufficientlyInUse {
            logger.info("Location insufficientlyInUse")
          }
          if update.locationUnavailable {
            continuation.yield(.error(.authorizationRestricted))
            logger.info("Location locationUnavailable")
            break
          }
          if update.serviceSessionRequired {
            logger.info("Location serviceSessionRequired")
          }
          if update.stationary {
            logger.info("Location stationary")
          }
        }
      } catch {
        print("error=\(error)")
        assertionFailure() // TODO: handle error
      }
      started = false
      logger.info("LocationManager stopped")
    }
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
#endif // DEBUG

