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
  var lastUpdate: CLLocationUpdate?
  let logger = Logger(subsystem: "com.moofus.moofuslist", category: "LocationManager")

  private(set) var count = 0
  var lastLocation = CLLocation()
  var started = false {
    didSet {
      if started {
        count = 0
        start()
      }
    }
  }

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
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
    }
  }
}
