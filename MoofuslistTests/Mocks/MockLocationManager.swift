//
//  MockLocationManager.swift
//  MoofuslistTests
//
//  Created by Lamar Williams III on 2/24/26.
//

import CoreLocation
import Testing
@testable import Moofuslist

actor MockLocationManager: LocationManaging {
  let stream: AsyncStream<LocationManager.Message>
  let continuation: AsyncStream<LocationManager.Message>.Continuation

  private(set) var startCallCount = 0

  init() {
    (stream, continuation) = AsyncStream<LocationManager.Message>.makeStream()
  }

  func start(maxCount: Int) {
    startCallCount += 1
  }

  func simulateLocation(_ location: CLLocation) {
    continuation.yield(.location(location))
  }

  func simulateError(_ error: LocationManager.Error) {
    continuation.yield(.error(error))
  }
}
