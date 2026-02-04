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
  @Test("For 1 location", .container)
  func test1Location() async {
    let maxCount = 1
    let (continuation, hooks, task) = initialize(maxCount: maxCount)

    let consumeTask = Task {
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

    let location = CLLocation(latitude: 37.334, longitude: -122.009)
    let mockLocationUpdate = MockLocationUpdate(
      location: location
    )
    continuation.yield(mockLocationUpdate)

    let messages = await consumeTask.value
    #expect(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .location(let location):
      #expect(location.coordinate.latitude == location.coordinate.latitude, "Latitude should match")
      #expect(location.coordinate.longitude == location.coordinate.longitude, "Longitude should match")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    // Clean up
    continuation.finish()
    _ = await task.value
  }

  @Test("For 2 locations", .container)
  func test2Locations() async {
    let maxCount = 2
    let (continuation, hooks, task) = initialize(maxCount: maxCount)

    let consumeTask = Task {
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

    let location1 = CLLocation(latitude: 37.334, longitude: -122.009)
    var mockLocationUpdate = MockLocationUpdate(
      location: location1
    )
    continuation.yield(mockLocationUpdate)

    let location2 = CLLocation(latitude: 10, longitude: 90)
    mockLocationUpdate = MockLocationUpdate(
      location: location2
    )
    continuation.yield(mockLocationUpdate)

    let messages = await consumeTask.value
    #expect(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .location(let location):
      #expect(location.coordinate.latitude == location1.coordinate.latitude, "Latitude should match")
      #expect(location.coordinate.longitude == location1.coordinate.longitude, "Longitude should match")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    switch messages[1] {
    case .info(let info):
      Issue.record("Expected location but got info: \(info)")
    case .location(let location):
      #expect(location.coordinate.latitude == location2.coordinate.latitude, "Latitude should match")
      #expect(location.coordinate.longitude == location2.coordinate.longitude, "Longitude should match")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
    }

    // Clean up
    continuation.finish()
    _ = await task.value
  }

  @Test("For accuracyLimited", .container)
  func testAccuracyLimited() async {
    let maxCount = 1
    let (continuation, hooks, task) = initialize(maxCount: maxCount)

    let consumeTask = Task {
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

    let mockLocationUpdate = MockLocationUpdate(
      accuracyLimited: true
    )
    continuation.yield(mockLocationUpdate)

    let messages = await consumeTask.value
    #expect(messages.count == maxCount, "messages.count=\(messages.count) should be \(maxCount)")

    switch messages[0] {
    case .info(let info):
      #expect(info == LocationManager.Info.accuracyLimited, "Info should be accuracyLimited")
    case .location(let location):
      Issue.record("Expected info but got info: \(location)")
    case .error(let error):
      Issue.record("Expected location but got error: \(error)")
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

  func initialize(maxCount: Int) -> (
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
