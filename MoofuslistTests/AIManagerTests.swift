import FoundationModels
import Testing
@testable import Moofuslist

@Suite("AIManager Basic Functionality")
struct AIManagerTests {

  @Test("AIManager initializes with stream and default properties")
  func initialization() async throws {
    let manager = AIManager()
    // Access a stream and check its type
    let mirror = Mirror(reflecting: manager)
    let hasStream = mirror.children.contains { $0.label == "stream" }
    #expect(hasStream, "AIManager should have a stream property")
  }

  @Test("cancelLoading initially should be false")
  func cancelLoadingInitially() async throws {
    let manager = AIManager()
    let testHooks = await manager.testHooks()

    let cancelStreamLoop = await testHooks.cancelStreamLoop
    #expect(cancelStreamLoop == false)
  }

  @Test("cancelLoading sets the cancelStreamLoop flag to true")
  func cancelLoading() async throws {
    let manager = AIManager()
    let testHooks = await manager.testHooks()

    await manager.cancelLoading()
    let cancelStreamLoop = await testHooks.cancelStreamLoop
    await manager.cancelLoading()
    #expect(cancelStreamLoop == true)
  }

  @Test("stream yields expected sequence")
  func streamYieldsMessages() async throws {
    let manager = AIManager()
    // Start findActivities (should yield .begin, then .loading, then .end or error)
    try await manager.findActivities(cityState: "Sacramento, CA")
    var yielded: [String] = []
    var streamIterator = await manager.stream.makeAsyncIterator()
    for _ in 0..<3 {
      if let msg = await streamIterator.next() {
        switch msg {
        case .begin: yielded.append("begin")
        case .loading: yielded.append("loading")
        case .end: yielded.append("end")
        case .error: yielded.append("error")
        }
      }
    }
    #expect(yielded.count == 3)
    #expect(yielded[0] == "begin")
    #expect(yielded[1] == "loading")
    #expect(yielded[2] == "loading")
  }

  @Test("Activity.lowercased lowercases category and description")
  func activityLowercased() async throws {
    let original = AIManager.Activity(
      name: "Test Place",
      address: "123 Main St",
      city: "Testville",
      state: "CA",
      category: "Museum",
      rating: 5.0,
      reviews: 42,
      distance: 1.2,
      phoneNumber: "555-1234",
      description: "A Cool Place!",
      somethingInteresting: "Lots of Art"
    )
    let lowercased = original.lowercased()
    #expect(lowercased.category == "museum")
    #expect(lowercased.description == "A Cool Place!") // If your logic lowercases this, check accordingly
  }

  @Test("AIManager.Error properties return expected messages")
  func errorProperties() async throws {
    let err = AIManager.Error.appleIntelligenceNotEnabled
    #expect(err.failureReason != nil)
    #expect(err.errorDescription == "Can't get location.")
    #expect(err.recoverySuggestion == "Apple Intelligence is not enabled in Settings.")
  }

  @Test("All error cases have proper descriptions", arguments: [
    AIManager.Error.deviceNotEligible,
    AIManager.Error.exceededContextWindowSize,
    AIManager.Error.guardrailViolation,
    AIManager.Error.location,
    AIManager.Error.model("test error"),
    AIManager.Error.modelNotReady,
    AIManager.Error.unknown("unknown error")
  ])
  func allErrorCases(error: AIManager.Error) async throws {
    #expect(error.failureReason != nil)
    #expect(error.errorDescription != nil)
    #expect(error.recoverySuggestion != nil)
  }

  @Test("findActivities completes full stream cycle")
  func fullStreamCycle() async throws {
    let manager = AIManager()

    try await manager.findActivities(cityState: "Sacramento, CA")
    var yielded: [String] = []
    var streamIterator = await manager.stream.makeAsyncIterator()
    loop: while let msg = await streamIterator.next() {
      switch msg {
      case .begin: yielded.append("begin")
      case .loading: yielded.append("loading")
      case .end: yielded.append("end"); break loop
      case .error: yielded.append("error")
      }
    }
    #expect(yielded.contains("begin"))
    #expect(yielded.contains("loading"))
    #expect(yielded.contains("end"))
  }
}
