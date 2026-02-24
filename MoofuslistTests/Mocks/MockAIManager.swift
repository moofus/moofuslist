//
//  MockAIManager.swift
//  MoofuslistTests
//
//  Created by Lamar Williams III on 2/24/26.
//

import Testing
@testable import Moofuslist

actor MockAIManager: AIManaging {
  private let continuation: AsyncStream<AIManager.Message>.Continuation
  let stream: AsyncStream<AIManager.Message>

  private(set) var cancelLoadingCallCount = 0
  private(set) var findActivitiesCallCount = 0
  private(set) var lastCityState: String?

  var shouldThrowError: AIManager.Error?
  var mockActivities: [AIManager.Activity] = globalMockActivities
  var shouldSimulateStreaming = true
  var streamDelay: Duration = .milliseconds(10)

  init() {
    (stream, continuation) = AsyncStream<AIManager.Message>.makeStream()
  }

  func cancelLoading() {
    cancelLoadingCallCount += 1
  }

  func findActivities(cityState: String) async throws {
    findActivitiesCallCount += 1
    lastCityState = cityState

    if let error = shouldThrowError {
      continuation.yield(.error(error))
      throw error
    }

    continuation.yield(.begin)

    if shouldSimulateStreaming {
      // Simulate streaming partial results
      for idx in stride(from: 1, through: mockActivities.count, by: 2) {
        try await Task.sleep(for: streamDelay)
        let batch = Array(mockActivities.prefix(idx))
        continuation.yield(.loading(batch))
      }

      // Send final complete batch
      if !mockActivities.isEmpty {
        try await Task.sleep(for: streamDelay)
        continuation.yield(.loading(mockActivities))
      }
    } else {
      // Send all at once
      continuation.yield(.loading(mockActivities))
    }

    continuation.yield(.end)
  }

  // Helper methods for testing
  func reset() {
    cancelLoadingCallCount = 0
    findActivitiesCallCount = 0
    lastCityState = nil
    shouldThrowError = nil
    mockActivities = []
    shouldSimulateStreaming = true
  }

  func simulateError(_ error: AIManager.Error) {
    continuation.yield(.error(error))
  }

  // Actor-safe setters for configuration
  func setMockActivities(_ activities: [AIManager.Activity]) {
    mockActivities = activities
  }

  func setError(_ error: AIManager.Error?) {
    shouldThrowError = error
  }

  func setSimulateStreaming(_ value: Bool) {
    shouldSimulateStreaming = value
  }

  func setStreamDelay(_ delay: Duration) {
    streamDelay = delay
  }
}

struct MockAIManagerTests {
  @Test("MockAIManager can be created and configured")
  func testMockAIManagerBasics() async throws {
    let mock = MockAIManager()
    await mock.setMockActivities([globalMockActivities[0]])

    let count = await mock.findActivitiesCallCount
    #expect(count == 0)

    try await mock.findActivities(cityState: "Cupertino, CA")

    let newCount = await mock.findActivitiesCallCount
    #expect(newCount == 1)

    let cityState = await mock.lastCityState
    #expect(cityState == "Cupertino, CA")
  }

  @Test("Verify mock AIManager stream behavior")
  func testMockAIManagerStream() async throws {
    let mock = MockAIManager()
    await mock.setMockActivities([globalMockActivities[0]])
    await mock.setSimulateStreaming(false) // Send all at once for faster test

    // Collect stream messages
    var messages: [AIManager.Message] = []
    let collectTask = Task {
      for await message in mock.stream {
        messages.append(message)
        if case .end = message {
          break
        }
      }
    }

    // Trigger the activity search
    try await mock.findActivities(cityState: "Cupertino, CA")

    // Wait for stream to complete
    await collectTask.value

    // Verify call tracking
    let callCount = await mock.findActivitiesCallCount
    #expect(callCount == 1)

    let cityState = await mock.lastCityState
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

  @Test("Mock AIManager error handling")
  func testMockAIManagerError() async throws {
    let mock = MockAIManager()
    await mock.setError(.deviceNotEligible)

    // Expect the error to be thrown
    do {
      try await mock.findActivities(cityState: "Test, CA")
      Issue.record("Expected error to be thrown")
    } catch let error as AIManager.Error {
      #expect(error == .deviceNotEligible)
    }
  }
}

// swiftlint:disable line_length
let globalMockActivities: [AIManager.Activity] = [
    AIManager.Activity(name: "Test Restaurant", address: "123 Main St, Cupertino, CA", city: "Cupertino", state: "CA", category: "restaurant", rating: 4.5, reviews: 100, distance: 2.5, phoneNumber: "555-1234", description: "A great place to eat", somethingInteresting: "Famous for its pizza"
    ),

  AIManager.Activity(name: "white rock lake", address: "White Rock Lake Park, Alamogordo, NM 88311", city: "Alamogordo", state: "New Mexico", category: "recreational area", rating: 4.3, reviews: 250, distance: 125.0, phoneNumber: "(575) 523-5200", description: "white rock lake is a popular spot for boating, fishing, and picnicking, surrounded by scenic views and hiking trails.", somethingInteresting: "The lake is part of a man-made reservoir, created by the White Rock Dam, and is a hub for outdoor recreation in the region."),

  AIManager.Activity(name: "las cruces botanic garden", address: "2250 N Sierra Vista Dr, Las Cruces, NM 88005", city: "Las Cruces", state: "New Mexico", category: "botanical garden", rating: 4.4, reviews: 220, distance: 130.0, phoneNumber: "(575) 522-2400", description: "the las cruces botanic garden features a diverse collection of plants from around the world, offering beautiful gardens and educational programs.", somethingInteresting: "The garden is home to a wide variety of plant species, including desert flora and tropical plants, creating a unique ecosystem."),

  AIManager.Activity(name: "chaco culture national historical park", address: "2400 Chaco Culture Way, Aztec, NM 87101", city: "Aztec", state: "New Mexico", category: "historical site", rating: 4.6, reviews: 180, distance: 180.0, phoneNumber: "(575) 522-2400", description: "chaco culture national historical park showcases ancient cliff dwellings and ruins built by the ancestral puebloans, reflecting their sophisticated architectural skills.", somethingInteresting: "The park includes the well-preserved structures of Pueblo Bonito, one of the largest and most significant archaeological sites in the Southwest."),

  AIManager.Activity(name: "roswell international ufo museum and research center", address: "14110 4th St SW, Roswell, NM 88201", city: "Roswell", state: "New Mexico", category: "museum", rating: 4.5, reviews: 350, distance: 200.0, phoneNumber: "(575) 988-4200", description: "the museum is dedicated to the study and exhibition of ufos and extraterrestrial phenomena, featuring a vast collection of artifacts and exhibits.", somethingInteresting: "Roswell is famous for the 1947 UFO incident, and the museum plays a central role in this ongoing mystery."),

  AIManager.Activity(name: "taos pueblo", address: "480 Pueblo Rd, Taos, NM 87846", city: "Taos", state: "New Mexico", category: "cultural landmark", rating: 4.9, reviews: 200, distance: 150.0, phoneNumber: "(575) 751-1880", description: "taos pueblo is a living native american community with a rich history dating back over 900 years. visitors can explore the historic dwellings and learn about the pueblo culture.", somethingInteresting: "The pueblo is one of the oldest continuously inhabited communities in the United States, with a history that predates European settlement."),

  AIManager.Activity(name: "carlsbad caverns national park", address: "24005 Cavern Rd, Carlsbad, NM 88220", city: "Carlsbad", state: "New Mexico", category: "national park", rating: 4.7, reviews: 300, distance: 175.0, phoneNumber: "(575) 522-2400", description: "carlsbad caverns is home to the big room, the largest known cave chamber in the world. visitors can explore the stunning underground formations and guided tours.", somethingInteresting: "The park features more than 200 miles of mapped cave passages, with the Big Room being the centerpiece attraction."),

  AIManager.Activity(name: "white sands national park", address: "17070 White Sands Rd, Alamogordo, NM 88311", city: "Alamogordo", state: "New Mexico", category: "national park", rating: 4.8, reviews: 150, distance: 125.0, phoneNumber: "(575) 523-5200", description: "white sands national park is known for its stunning gypsum sand dunes, which can be seen from space. visitors can hike, sand sledding, and enjoy breathtaking views.", somethingInteresting: "The park\'s dunes are made of gypsum, which is the same mineral that makes up drywall, giving them a unique texture and color.")
]
// swiftlint:enable line_length
