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
@testable import Moofuslist

// swiftlint:disable file_length type_body_length
struct LocationManagerTests {
  @Test("Errors", .container, arguments: [
    MockLocationUpdate(authorizationDenied: true),
    MockLocationUpdate(authorizationDeniedGlobally: true),
    MockLocationUpdate(authorizationRestricted: true),
    MockLocationUpdate(locationUnavailable: true)
  ])
  func testErrors(locationUpdate: MockLocationUpdate) async throws {
    let maxCount = 1
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    continuation.yield(locationUpdate)
    continuation.finish()

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
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    continuation.yield(locationUpdate)

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      if locationUpdate.accuracyLimited {
        try #require(info == LocationManager.Info.accuracyLimited, "Info should be accuracyLimited")
      } else if locationUpdate.authorizationRequestInProgress {
        try #require(
          info == LocationManager.Info.authorizationRequestInProgress,
          "Info should be authorizationRequestInProgress"
        )
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
    _ = await task.value
  }

  @Test("Locations", .container, arguments: [
    [ CLLocation(latitude: 37.334, longitude: -122.009) ],
    [ CLLocation(latitude: 37.334, longitude: -122.009), CLLocation(latitude: 10, longitude:90) ]
  ])
  func testLocations(locations: [CLLocation]) async throws {
    let maxCount = locations.count
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    for location in locations {
      let locationUpdate = MockLocationUpdate(location: location)
      continuation.yield(locationUpdate)
    }
    continuation.finish()

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
    _ = await task.value
  }

  struct MockLocationUpdate: LocationUpdateProtocol {
    var accuracyLimited = false
    var authorizationDenied = false
    var authorizationDeniedGlobally = false
    var authorizationRequestInProgress = false
    var authorizationRestricted = false
    var insufficientlyInUse = false
    var location: CLLocation?
    var locationUnavailable = false
    var serviceSessionRequired = false
    var stationary = false
  }

  struct MockLocationUpdates: LocationUpdateStream {
    // swiftlint:disable nesting
    typealias Element = MockLocationUpdate
    // swiftlint:enable nesting

    private let stream: AsyncStream<MockLocationUpdate>

    init(stream: AsyncStream<MockLocationUpdate>) {
      self.stream = stream
    }

    func makeAsyncIterator() -> AsyncStream<MockLocationUpdate>.Iterator {
      return stream.makeAsyncIterator()
    }
  }

  private func consumeTask(
    hooks: LocationManager.TestHooks,
    maxCount: Int
  ) -> Task<[LocationManager.Message], Never> {
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

  // swiftlint:disable large_tuple
  private func initialize(maxCount: Int) async -> (
    AsyncStream<MockLocationUpdate>.Continuation,
    LocationManager.TestHooks,
    task: Task<(), Never>
  ) {
    let (stream, continuation) = AsyncStream<MockLocationUpdate>.makeStream()
    let mockSequence = MockLocationUpdates(stream: stream)
    Container.shared.liveUpdates.register { mockSequence }
    let locationManager = LocationManager()
    let hooks = await locationManager.testHooks()
    let task = Task {
      await hooks.start(maxCount: maxCount)
    }
    return (continuation, hooks, task)
  }
  // swiftlint:enable large_tuple

  @Test("maxCount stops processing")
  func testMaxCountLimit() async throws {
    // Verify that after maxCount locations, no more are processed
    let maxCount = 2
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    // Send 3 locations but only expect 2
    let locations = [
      CLLocation(latitude: 37.334, longitude: -122.009),
      CLLocation(latitude: 38.0, longitude: -121.0),
      CLLocation(latitude: 39.0, longitude: -120.0)
    ]

    for location in locations {
      continuation.yield(MockLocationUpdate(location: location))
    }
    continuation.finish()

    let messages = await consumeTask.value

    // Should only receive maxCount messages
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    // Verify we got locations, not errors
    for message in messages {
      switch message {
      case .location:
        break // Expected
      case .info(let info):
        Issue.record("Expected location but got info: \(info)")
      case .error(let error):
        Issue.record("Expected location but got error: \(error)")
      }
    }

    // Clean up
    _ = await task.value
  }

  @Test("count increments correctly")
  func testCountTracking() async throws {
    // Verify count property increases with each location
    let maxCount = 3
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    let locations = [
      CLLocation(latitude: 37.334, longitude: -122.009),
      CLLocation(latitude: 38.0, longitude: -121.0),
      CLLocation(latitude: 39.0, longitude: -120.0)
    ]

    for location in locations {
      continuation.yield(MockLocationUpdate(location: location))
    }
    continuation.finish()

    _ = await consumeTask.value

    // Clean up and wait for processUpdates to complete
    _ = await task.value

    // Verify count is correct (after task completion ensures all updates are processed)
    let count = await hooks.count()
    try #require(count == maxCount, "count=\(count) should be \(maxCount)")
  }

  @Test("authorizationRequestInProgress allows continued processing")
  func testAuthRequestContinues() async throws {
    // Send authRequestInProgress, then a location, verify both received
    let maxCount = 2
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    // Send authorization request in progress (should continue, not break)
    continuation.yield(MockLocationUpdate(authorizationRequestInProgress: true))

    // Send a location afterward
    continuation.yield(MockLocationUpdate(location: CLLocation(latitude: 37.334, longitude: -122.009)))

    continuation.finish()

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    // First message should be info about authorization request
    switch messages[0] {
    case .info(let info):
      try #require(
        info == LocationManager.Info.authorizationRequestInProgress,
        "First message should be authorizationRequestInProgress"
      )
    case .location(let location):
      Issue.record("Expected info but got location: \(location)")
    case .error(let error):
      Issue.record("Expected info but got error: \(error)")
    }

    // Second message should be the location
    switch messages[1] {
    case .location(let location):
      try #require(location.coordinate.latitude == 37.334, "Latitude should match")
      try #require(location.coordinate.longitude == -122.009, "Longitude should match")
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    // Clean up
    _ = await task.value
  }

  // swiftlint:disable cyclomatic_complexity
  @Test("mixed message sequences")
  func testMixedSequences() async throws {
    // Test location → info → location sequences
    let maxCount = 4
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    // Send mixed sequence: location → info → info → location
    continuation.yield(MockLocationUpdate(location: CLLocation(latitude: 37.334, longitude: -122.009)))
    continuation.yield(MockLocationUpdate(accuracyLimited: true))
    continuation.yield(MockLocationUpdate(stationary: true))
    continuation.yield(MockLocationUpdate(location: CLLocation(latitude: 38.0, longitude: -121.0)))

    continuation.finish()

    let messages = await consumeTask.value
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    // Verify sequence
    switch messages[0] {
    case .location(let location):
      try #require(location.coordinate.latitude == 37.334, "First message should be first location")
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    switch messages[1] {
    case .info(let info):
      try #require(info == LocationManager.Info.accuracyLimited, "Second message should be accuracyLimited")
    case .location(let location):
      Issue.record("Expected info but got location: \(location)")
    case .error(let error):
      Issue.record("Expected info but got error: \(error)")
    }

    switch messages[2] {
    case .info(let info):
      try #require(info == LocationManager.Info.stationary, "Third message should be stationary")
    case .location(let location):
      Issue.record("Expected info but got location: \(location)")
    case .error(let error):
      Issue.record("Expected info but got error: \(error)")
    }

    switch messages[3] {
    case .location(let location):
      try #require(location.coordinate.latitude == 38.0, "Fourth message should be second location")
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    // Verify count only increments for locations, not infos
    let count = await hooks.count()
    try #require(count == 2, "count=\(count) should be 2 (only locations, not infos)")

    // Clean up
    _ = await task.value
  }
  // swiftlint:enable cyclomatic_complexity

  @Test("breaking errors stop processing subsequent updates")
  func testBreakingErrorsStopProcessing() async throws {
    // Verify that after a breaking error, no further updates are processed
    let maxCount = 2
    let (continuation, hooks, task) = await initialize(maxCount: maxCount)
    let consumeTask = consumeTask(hooks: hooks, maxCount: maxCount)

    // Send a location first
    continuation.yield(MockLocationUpdate(location: CLLocation(latitude: 37.334, longitude: -122.009)))

    // Send a breaking error
    continuation.yield(MockLocationUpdate(authorizationDenied: true))

    // Try to send another location after the error (should not be processed)
    continuation.yield(MockLocationUpdate(location: CLLocation(latitude: 38.0, longitude: -121.0)))

    // Finish the stream to unblock the for-await loop
    continuation.finish()

    let messages = await consumeTask.value

    // Should only receive 2 messages (location + error), not the third location
    try #require(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    // First should be location
    switch messages[0] {
    case .location:
      break // Expected
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    // Second should be error
    switch messages[1] {
    case .error(let error):
      try #require(error == LocationManager.Error.authorizationDenied, "Should be authorizationDenied error")
    case .location(let location):
      Issue.record("Expected error but got location: \(location)")
    case .info(let info):
      Issue.record("Expected error but got info: \(info)")
    }

    // Wait for task completion
    _ = await task.value

    // Verify count is only 1 (first location, not the one after error)
    let count = await hooks.count()
    try #require(count == 1, "count=\(count) should be 1 (location after error should not be counted)")
  }
}
// swiftlint:enable file_length type_body_length
