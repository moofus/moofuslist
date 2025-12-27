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


actor LocationManager {
  var haveError = false
  private var task: Task<Void,Never>? = nil

  private(set) var count = 0 // ljw delete
  private(set) var error: LocationError?
  private var lastUpdate: CLLocationUpdate? // ljw delete?
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "LocationManager")

  var started = false {
    didSet {
      if started {
        reset()
        start()
      }
    }
  }

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
  }

  private func reset() {
    count = 0
    error = nil
    haveError = false
    lastUpdate = nil
    task?.cancel()
    task = nil
  }

  private func start() {
    logger.info("LocationManager starting")
    task = Task {
      do {
        let liveUpdates = CLLocationUpdate.liveUpdates()
        for try await update in liveUpdates {
          print("top")
          if Task.isCancelled { print("ljw break"); break }
          if !started { print("ljw started break");break }
          lastUpdate = update
          if let location = update.location {
            count += 1
            logger.info("count=\(self.count) location=\(location)")
          }
          if update.accuracyLimited {
            logger.info("Location accuracyLimited: Moofuslist can't access your precise location, using approximate location")
          }
          if update.authorizationDeniedGlobally {
            self.error = LocationError.authorizationDeniedGlobally
            self.haveError = true
            logger.info("Location authorizationDeniedGlobally")
            break
          }
          if update.authorizationDenied {
            self.error = LocationError.authorizationDenied
            self.haveError = true
            logger.info("Location authorizationDenied")
            break
          }
          if update.authorizationRequestInProgress {
            logger.info("Location authorizationRequestInProgress")
            continue
          }
          if update.authorizationRestricted {
            self.error = LocationError.authorizationRestricted
            self.haveError = true
            logger.info("Location authorizationDenied, maybe disable Parental Controls?")
            break
          }
          if update.insufficientlyInUse {
            logger.info("Location insufficientlyInUse")
          }
          if update.locationUnavailable {
            logger.info("Location locationUnavailable")
          }
          if update.serviceSessionRequired {
            logger.info("Location serviceSessionRequired")
          }
          if update.stationary {
            logger.info("Location stationary")
          }
        }
      } catch {
        print("ljw \(Date()) \(#file):\(#function):\(#line)")
        print("error=\(error)")
      }
      logger.info("LocationManager stopped")
    }
  }}

extension LocationManager {
  enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationDeniedGlobally
    case authorizationRestricted

    var failureReason: String? {
      switch self {
      case .authorizationDenied:
        "User denied location permissions for Moofuslist or location services are turned off or device is in Airplane mode"
      case .authorizationDeniedGlobally: "Location Services are disabled for this device."
      case .authorizationRestricted: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      }
    }

    var errorDescription: String? {
      switch self {
      case .authorizationDenied: fallthrough
      case .authorizationDeniedGlobally: fallthrough
      case .authorizationRestricted: "Can't get location."
      }
    }

    var recoverySuggestion: String? {
      switch self {
      case .authorizationDenied: "Please authorize Moofuslist to access Location Services"
      case .authorizationDeniedGlobally: "Please enable Location Services by going to Settings -> Privacy & Security"
      case .authorizationRestricted: "Maybe disable Parental Controls?"
      }
    }
  }
}

extension LocationManager {
  var lastLocation: CLLocation? {
    lastUpdate?.location
  }
}

// MARK: - Public Methods
extension LocationManager {
  func stop() {
    started = false
    task?.cancel()
    task = nil
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

#Preview {
  JunkView()
}

#endif // DEBUG

