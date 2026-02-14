//
//  LocationManagerTests.swift
//  LocationManagerTests
//
//  Created by Lamar Williams III on 2/3/26.
//

import CoreLocation
import FactoryKit
import FactoryTesting
import Testing
@testable import moofuslist

// CLLocationUpdate.liveUpdates()

struct LocationManagerTests {
  @Test("Errors", .container, arguments: [
    MockLocationUpdate(authorizationDenied: true),
    MockLocationUpdate(authorizationDeniedGlobally: true),
    MockLocationUpdate(authorizationRestricted: true),
    MockLocationUpdate(locationUnavailable: true)
  ])
  func testErrors(locationUpdate: MockLocationUpdate) async throws {
    let maxCount = 1
    let (continuation, hooks, task) = initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

     continuation.yield(locationUpdate)

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      Issue.record("Expected error but got info: \(info)")
    case .location(let location):
      Issue.record("Expected info but got info: \(location)")
    case .error(let error):
        switch error {
        case .authorizationDenied:
          try #require(locationUpdate.authorizationDenied, "error should be authorizationDenied")
        case .authorizationDeniedGlobally:
          try #require(locationUpdate.authorizationDeniedGlobally, "error should be authorizationDeniedGlobally")
        case .authorizationRestricted:
          try #require(locationUpdate.authorizationRestricted, "error should be authorizationRestricted")
        case .locationUnavailable:
          try #require(locationUpdate.locationUnavailable, "error should be locationUnavailable")
        case .unknown:
          Issue.record("Did not expect error: \(error)")
        }
    }

    // Clean up
    continuation.finish()
    _ = await task.value
  }

  @Test("Infos", .container, arguments: [
    MockLocationUpdate(accuracyLimited: true),
    MockLocationUpdate(authorizationRequestInProgress: true),
    MockLocationUpdate(insufficientlyInUse: true),
    MockLocationUpdate(serviceSessionRequired: true),
    MockLocationUpdate(stationary: true)
  ])
  func testInfos(locationUpdate: MockLocationUpdate) async throws {
    let maxCount = 1
    let (continuation, hooks, task) = initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

     continuation.yield(locationUpdate)

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      if locationUpdate.accuracyLimited {
        try #require(info == LocationManager.Info.accuracyLimited, "Info should be accuracyLimited")
      } else if locationUpdate.authorizationRequestInProgress {
        try #require(info == LocationManager.Info.authorizationRequestInProgress, "Info should be authorizationRequestInProgress")
      } else if locationUpdate.insufficientlyInUse {
        try #require(info == LocationManager.Info.insufficientlyInUse, "Info should be insufficientlyInUse")
      } else if locationUpdate.serviceSessionRequired {
        try #require(info == LocationManager.Info.serviceSessionRequired, "Info should be serviceSessionRequired")
      } else if locationUpdate.stationary {
        try #require(info == LocationManager.Info.stationary, "Info should be stationary")
      } else {
        Issue.record("Unexpected info state: none of the expected flags were set")
      }
    case .location(let location):
      Issue.record("Expected info but got info: \(location)")
    case .error(let error):
      Issue.record("Expected info but got error: \(error)")
    }

    // Clean up
    continuation.finish()
    _ = await task.value
  }

  @Test("Locations", .container, arguments: [
    [ CLLocation(latitude: 37.334, longitude: -122.009) ],
    [ CLLocation(latitude: 37.334, longitude: -122.009), CLLocation(latitude: 10, longitude:90) ]
  ])
  func testLocations(locations: [CLLocation]) async throws {
    let maxCount = locations.count
    let (continuation, hooks, task) = initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    for location in locations {
      let locationUpdate = MockLocationUpdate(location: location)
      continuation.yield(locationUpdate)
    }

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    for (idx, message) in messages.enumerated() {
      switch message {
      case .info(let info):
        Issue.record("Expected location but got info: \(info)")
      case .location(let location):
        try #require(location.coordinate.latitude == locations[idx].coordinate.latitude, "Latitude should match")
        try #require(location.coordinate.longitude == locations[idx].coordinate.longitude, "Longitude should match")
      case .error(let error):
        Issue.record("Expected location but got error: \(error)")
      }
    }

    // Clean up
    continuation.finish()
    _ = await task.value
  }

  struct MockLocationUpdate: LocationUpdateProtocol {
    var accuracyLimited = false
    var authorizationDenied = false
    var authorizationDeniedGlobally = false
    var authorizationRequestInProgress = false
    var authorizationRestricted = false
    var insufficientlyInUse = false
    var location: CLLocation? = nil
    var locationUnavailable = false
    var serviceSessionRequired = false
    var stationary = false
  }

  struct MockLocationUpdates: LocationUpdateStream {
    typealias Element = MockLocationUpdate

    private let stream: AsyncStream<MockLocationUpdate>

    init(stream: AsyncStream<MockLocationUpdate>) {
      self.stream = stream
    }

    func makeAsyncIterator() -> AsyncStream<MockLocationUpdate>.Iterator {
      return stream.makeAsyncIterator()
    }
  }

  private func consumeTask(hooks: LocationManager.TestHooks, maxCount: Int) -> Task<[LocationManager.Message], Never> {
    Task {
      var messages = [LocationManager.Message]()
      var tmpCount = 0
      for await data in hooks.stream {
        messages.append(data)
        tmpCount += 1
        if tmpCount == maxCount {
          break
        }
      }
      return messages
    }
  }

  private func initialize(maxCount: Int) -> (
    AsyncStream<MockLocationUpdate>.Continuation,
    LocationManager.TestHooks, task: Task<(), Never>
  ) {
    let (stream, continuation) = AsyncStream<MockLocationUpdate>.makeStream()
    let mockSequence = MockLocationUpdates(stream: stream)
    Container.shared.liveUpdates.register { mockSequence }
    let locationManager = LocationManager()
    let hooks = locationManager.testHooks()
    let task = Task {
      await hooks.start(maxCount: maxCount)
    }
    return (continuation, hooks, task)
  }
}
