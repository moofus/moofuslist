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

@MainActor
@Observable
class LocationManager {
  enum LocationError: LocalizedError {
    static let globalAuthDeniedError = "Please enable Location Services by going to Settings -> Privacy & Security."

    case authorizationDeniedGlobally

    var failureReason: String? {
      switch self {
      case .authorizationDeniedGlobally: "Location Services are disabled for this device."
      }
    }

    var errorDescription: String? {
      switch self {
      case .authorizationDeniedGlobally: "Can't get location."
      }
    }

    var recoverySuggestion: String? {
      switch self {
      case .authorizationDeniedGlobally:  "Please enable Location Services by going to Settings -> Privacy & Security"
      }
    }
  }

  private var lastUpdate: CLLocationUpdate?
  private(set) var error: LocationError?
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "LocationManager")
  var haveError = false

  private(set) var count = 0
  var lastLocation = CLLocation()
  var started = false {
    didSet {
      if started {
        reset()
        start()
      }
    }
  }

  func reset() {
    count = 0
    error = nil
    haveError = false
    lastUpdate = nil
  }

  func stop() {
    started = false
  }

  func start() {
    Task {
      do {
        let liveUpdates = CLLocationUpdate.liveUpdates()
        for try await update in liveUpdates {
          if !started { break }
          lastUpdate = update
          if let location = update.location {
            count += 1
            lastLocation = location
            logger.info("count=\(self.count) location=\(location)")
          }
          print("accuracyLimited=\(update.accuracyLimited)")
          print("authorizationDenied=\(update.authorizationDenied)")
          print("authorizationDeniedGlobally=\(update.authorizationDeniedGlobally)")
          if update.authorizationDeniedGlobally {
            self.error = LocationError.authorizationDeniedGlobally
            self.haveError = true
            break
          }
          print("authorizationRequestInProgress=\(update.authorizationRequestInProgress)")
          print("authorizationRestricted=\(update.authorizationRestricted)")
          print("insufficientlyInUse=\(update.insufficientlyInUse)")
          print("locationUnavailable=\(update.locationUnavailable)")
          print("serviceSessionRequired=\(update.serviceSessionRequired)")
          print("stationary=\(update.stationary)")
        }
      } catch {
        print("ljw \(Date()) \(#file):\(#function):\(#line)")
        print("error=\(error)")
      }
      logger.info("LocationManager stopped")
    }
  }
}
