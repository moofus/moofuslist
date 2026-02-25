//
//  MoofuslistSourceTests.swift
//  MoofuslistTests
//
//  Created by Lamar Williams III on 2/23/26.
//

import CoreLocation
import FactoryKit
import FactoryTesting
import Foundation
import MapKit
import SwiftData
import Testing
@testable import Moofuslist

struct MoofuslistSourceTests {

  @Test("Search city state with mocked dependencies", .container)
  func testSearchCityStateWithMocks() async throws {
    let mockAI = MockAIManager()
    await mockAI.setMockActivities([globalMockActivities[0]])
    await mockAI.setSimulateStreaming(false) // Send all at once for faster test

    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    // Create source with mocked dependencies
    let source = MoofuslistSource()

    // Collect messages from the stream
    let collectTask = consumeTask(source: source)

    // Give initialization time to complete
    try await Task.sleep(for: .milliseconds(100))

    // Trigger the search
    source.searchCityState("Cupertino, CA")

    let messages: [MoofuslistSource.Message]
    do {
      // Wait for stream to complete or timeout
      messages = try await executeWith(task: collectTask, timeout: .seconds(5))
    } catch is TimeoutError {
      Issue.record("Test timed out waiting for messages")
      return
    } catch {
      Issue.record("Unexpected error: \(error)")
      return
    }

    let callCount = await mockAI.findActivitiesCallCount
    #expect(callCount == 1, "AIManager should be called once")

    let cityState = await mockAI.lastCityState
    #expect(cityState == "Cupertino, CA", "Should search for correct city/state")

    var foundInitialize = false
    var foundProcessing = false
    var foundLoading = false
    var foundLoaded = false

    for message in messages {
      switch message {
      case .initialize:
        foundInitialize = true
      case .processing:
        foundProcessing = true
      case .loading(let activities, let favorites, _):
        foundLoading = true
        #expect(!activities.isEmpty, "Should have activities")
        #expect(favorites == false, "Should not be favorites")
      case .loaded(let loading):
        foundLoaded = true
        #expect(loading == false, "Should be done loading")
      default:
        break
      }
    }

    #expect(foundInitialize, "Should send initialize message")
    #expect(foundProcessing, "Should send processing message")
    #expect(foundLoading, "Should send loading message with activities")
    #expect(foundLoaded, "Should send loaded message")
  }

  @Test("Verify mock AIManager stream behavior")
  func testMockAIManagerStream() async throws {
    let mockAI = MockAIManager()
    await mockAI.setMockActivities([globalMockActivities[0]])
    await mockAI.setSimulateStreaming(false) // Send all at once for faster test

    // Collect stream messages
    var messages: [AIManager.Message] = []
    let collectTask = Task {
      for await message in mockAI.stream {
        messages.append(message)
        if case .end = message {
          break
        }
      }
    }

    // Trigger the activity search
    try await mockAI.findActivities(cityState: "Cupertino, CA")

    // Wait for stream to complete
    await collectTask.value

    // Verify call tracking
    let callCount = await mockAI.findActivitiesCallCount
    #expect(callCount == 1)

    let cityState = await mockAI.lastCityState
    #expect(cityState == "Cupertino, CA")

    // Verify messages received
    #expect(messages.count == 3) // .begin, .loading, .end

    var foundBegin = false
    var foundLoading = false
    var foundEnd = false

    for message in messages {
      switch message {
      case .begin: foundBegin = true
      case .loading: foundLoading = true
      case .end: foundEnd = true
      case .error: break
      }
    }

    #expect(foundBegin)
    #expect(foundLoading)
    #expect(foundEnd)
  }

  @Test("cancelLoading forwards to AIManager", .container)
  func testCancelLoading() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    // Give init some time
    try await Task.sleep(for: .milliseconds(50))

    source.cancelLoading()

    // Allow the call to propagate
    try await Task.sleep(for: .milliseconds(50))

    let count = await mockAI.cancelLoadingCallCount
    #expect(count == 1, "cancelLoading should be forwarded once")
    _ = source // silence unused warning if any
  }

  @Test("searchCurrentLocation sends initialize and processing; starts location", .container)
  func testSearchCurrentLocation() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    // Prepare collector
    var messages: [MoofuslistSource.Message] = []
    let collectTask = Task {
      var collected = 0
      for await message in await source.stream {
        messages.append(message)
        collected += 1
        if collected >= 2 { // expecting .initialize and .processing
          break
        }
      }
      return messages
    }

    // Trigger search current location
    source.searchCurrentLocation()

    let result = await collectTask.value
    #expect(result.count >= 2)

    // Verify ordering contains initialize then processing in some form
    var sawInitialize = false
    var sawProcessing = false
    for msg in result {
      switch msg {
      case .initialize: sawInitialize = true
      case .processing: sawProcessing = true
      default: break
      }
    }
    #expect(sawInitialize)
    #expect(sawProcessing)

    let startCalls = await mockLocation.startCallCount
    #expect(startCalls == 1, "LocationManager.start should be called once")
  }

  @Test("loadMapItems emits message", .container)
  func testLoadMapItems() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    let collectTask = Task { () -> MoofuslistSource.Message? in
      for await message in await source.stream {
        if case .loadMapItems = message { return message }
      }
      return nil
    }

    source.loadMapItems()

    let msg = await collectTask.value
    #expect(msg != nil, "Should receive loadMapItems message")
  }

  @Test("selectActivity emits message", .container)
  func testSelectActivity() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    let targetId = UUID()

    let collectTask = Task { () -> UUID? in
      for await message in await source.stream {
        if case .selectActivity(let id) = message { return id }
      }
      return nil
    }

    source.selectActivity(for: targetId)

    let receivedId = await collectTask.value
    #expect(receivedId == targetId, "Should receive selectActivity with the same ID")
  }

  @Test("setIsFavorite with unknown ID emits error", .container)
  func testSetIsFavoriteUnknownId() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    let collectTask = Task { () -> Bool in
      for await message in await source.stream {
        if case .error(let desc, _) = message {
          return desc == "Activity not found"
        }
      }
      return false
    }

    source.setIsFavorite(true, for: UUID())

    let gotExpectedError = await collectTask.value
    #expect(gotExpectedError, "Should emit Activity not found error")
  }

  @Test("AI error from stream emits initialize and error", .container)
  func testAIErrorFromStream() async throws {
    let mockAI = MockAIManager()
    Container.shared.aiManager.register { mockAI }

    let mockLocation = MockLocationManager()
    Container.shared.locationManager.register { mockLocation }

    let source = MoofuslistSource()

    // Collect a small set of messages until we see .error
    let collectTask = Task { () -> [MoofuslistSource.Message] in
      var messages: [MoofuslistSource.Message] = []
      for await message in await source.stream {
        messages.append(message)
        if case .error = message { break }
      }
      return messages
    }

    // Simulate an AI error on the stream
    await mockAI.simulateError(.deviceNotEligible)

    let messages = await collectTask.value

    // We expect to have seen an initialize and an error
    let hasInitialize = messages.contains { if case .initialize = $0 { true } else { false } }
    let hasError = messages.contains { if case .error = $0 { true } else { false } }

    #expect(hasInitialize, "Should emit initialize after AI error")
    #expect(hasError, "Should emit error message after AI error")
  }
}

// MARK: - Utilities
extension MoofuslistSourceTests {
  func consumeTask(source: MoofuslistSource) -> Task<[MoofuslistSource.Message], Never> {
    var messages: [MoofuslistSource.Message] = []
    let collectTask = Task {
      for await message in await source.stream {
        messages.append(message)
        // Stop after we get loaded message
        if case .loaded = message {
          break
        }
      }
      return messages
    }
    return collectTask
  }

  struct TimeoutError: Error {}

  func executeWith(
    task: Task<[MoofuslistSource.Message], Never>,
    timeout: Duration
  ) async throws -> [MoofuslistSource.Message] {
    try await withThrowingTaskGroup(of: [MoofuslistSource.Message].self) { group in
      group.addTask { await task.value }
      group.addTask {
        try await Task.sleep(for: timeout)
        throw TimeoutError()
      }

      // Return the first one to complete
      let result = try await group.next()!
      group.cancelAll()
      return result
    }
  }
}

/*
 import Testing
 import FactoryKit
 import FactoryTesting
 @testable import Moofuslist

 struct MoofuslistSourceTests {

   @Test("Search city state returns activities", .container)
   func testSearchCityState() async throws {
     // Setup mock
     let mockAI = MockAIManager()
     await mockAI.mockActivities = [
       AIManager.Activity(
         name: "Test Location",
         address: "123 Main St",
         city: "Cupertino",
         state: "CA",
         category: "restaurant",
         rating: 4.5,
         reviews: 100,
         distance: 2.5,
         phoneNumber: "555-1234",
         description: "A great place",
         somethingInteresting: "Famous for something"
       )
     ]

     // Register the mock
     Container.shared.aiManager.register { mockAI }

     // Also need to mock LocationManager
     let mockLocation = MockLocationManager()
     Container.shared.locationManager.register { mockLocation }

     // Create the source
     let source = MoofuslistSource()

     // Collect messages
     var messages: [MoofuslistSource.Message] = []
     let collectTask = Task {
       for await message in source.stream {
         messages.append(message)
         // Break after we get loaded message
         if case .loaded = message {
           break
         }
       }
     }

     // Trigger the search
     source.searchCityState("Cupertino, CA")

     // Wait for completion
     await collectTask.value

     // Verify
     let callCount = await mockAI.findActivitiesCallCount
     #expect(callCount == 1)

     let cityState = await mockAI.lastCityState
     #expect(cityState == "Cupertino, CA")

     // Check that we received expected messages
     #expect(messages.contains { message in
       if case .loading = message { return true }
       return false
     })
   }

   @Test("Handle AI error gracefully", .container)
   func testAIError() async throws {
     let mockAI = MockAIManager()
     await mockAI.shouldThrowError = .deviceNotEligible

     Container.shared.aiManager.register { mockAI }

     let mockLocation = MockLocationManager()
     Container.shared.locationManager.register { mockLocation }

     let source = MoofuslistSource()

     var errorReceived = false
     let collectTask = Task {
       for await message in source.stream {
         if case .error = message {
           errorReceived = true
           break
         }
       }
     }

     source.searchCityState("Test City, CA")

     await collectTask.value

     #expect(errorReceived)
   }
 }

 // You'll also need a mock LocationManager
 #if DEBUG
 actor MockLocationManager: LocationManaging {
   let stream: AsyncStream<LocationManager.Message>
   let continuation: AsyncStream<LocationManager.Message>.Continuation

   private(set) var startCallCount = 0

   init() {
     (stream, continuation) = AsyncStream<LocationManager.Message>.makeStream()
   }

   func start(maxCount: Int) async {
     startCallCount += 1
   }
 }
 #endif
 */
