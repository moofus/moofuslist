//
//  StorageManagerTest.swift
//  MoofuslistTests
//
//  Created by Lamar Williams III on 2/22/26.
//

import Testing
import SwiftData
import Foundation
@testable import Moofuslist

// swiftlint:disable file_length function_body_length type_body_length

@Suite("StorageManager Tests")
struct StorageManagerTest {

  let container: ModelContainer
  let storageManager: StorageManager

  init() throws {
    let schema = Schema([MoofuslistActivityModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [configuration])
    storageManager = StorageManager(modelContainer: container)
  }

  // MARK: - Insert Tests
  @Test("Insert single activity")
  @MainActor
  func insertSingleActivity() async throws {
    let activity = createSampleActivity(name: "Pizza Place")
    try await storageManager.insert(activity: activity)

    let count = try await storageManager.countAllActivities()
    #expect(count == 1)

    let activities = try await storageManager.fetchAllActivities()
    #expect(activities.count == 1)
    #expect(activities.first?.name == "Pizza Place")
  }

  @Test("Insert multiple activities")
  func insertMultipleActivities() async throws {
    let models = [
      MoofuslistActivityModel(
        id: UUID(),
        address: "123 Main St",
        category: "Restaurant",
        city: "Oakland",
        desc: "Great food",
        distance: 1.0,
        imageNames: ["food"],
        isFavorite: false,
        latitude: 37.8044,
        longitude: -122.2712,
        name: "Restaurant 1",
        rating: 4.5,
        reviews: 100,
        phoneNumber: "555-0101",
        somethingInteresting: "Best pizza",
        state: "CA"
      ),
      MoofuslistActivityModel(
        id: UUID(),
        address: "456 Park Ave",
        category: "Park",
        city: "Oakland",
        desc: "Beautiful park",
        distance: 2.5,
        imageNames: ["tree"],
        isFavorite: true,
        latitude: 37.8044,
        longitude: -122.2712,
        name: "Park 1",
        rating: 4.8,
        reviews: 200,
        phoneNumber: "555-0102",
        somethingInteresting: "Great views",
        state: "CA"
      )
    ]

    try await storageManager.insert(activities: models)

    let count = try await storageManager.countAllActivities()
    #expect(count == 2)
  }

  // MARK: - Fetch Tests

  @Test("Fetch all activities")
  func fetchAllActivities() async throws {
    // Insert test data
    let activity1 = createSampleActivity(name: "Activity 1")
    let activity2 = createSampleActivity(name: "Activity 2")
    let activity3 = createSampleActivity(name: "Activity 3")

    try await storageManager.insert(activity: activity1)
    try await storageManager.insert(activity: activity2)
    try await storageManager.insert(activity: activity3)

    // Fetch all
    let activities = try await storageManager.fetchAllActivities()
    #expect(activities.count == 3)
  }

  @Test("Count all activities")
  func countAllActivities() async throws {
    let initialCount = try await storageManager.countAllActivities()
    #expect(initialCount == 0)

    // Add some activities
    try await storageManager.insert(activity: createSampleActivity())
    try await storageManager.insert(activity: createSampleActivity())

    let finalCount = try await storageManager.countAllActivities()
    #expect(finalCount == 2)
  }

  @Test("Fetch activities sorted by distance")
  func fetchActivitiesSortedByDistance() async throws {
    // Insert activities with different distances
    try await storageManager.insert(activity: createSampleActivity(name: "Far", distance: 5.0))
    try await storageManager.insert(activity: createSampleActivity(name: "Medium", distance: 2.5))
    try await storageManager.insert(activity: createSampleActivity(name: "Close", distance: 0.5))

    let sorted = try await storageManager.fetchActivitiesSortedByDistance()
    #expect(sorted.count == 3)
    #expect(sorted[0].name == "Close")
    #expect(sorted[1].name == "Medium")
    #expect(sorted[2].name == "Far")
    #expect(sorted[0].distance < sorted[1].distance)
    #expect(sorted[1].distance < sorted[2].distance)
  }

  @Test("Fetch activities sorted by rating")
  func fetchActivitiesSortedByRating() async throws {
    // Insert activities with different ratings
    try await storageManager.insert(activity: createSampleActivity(name: "Good", rating: 3.5))
    try await storageManager.insert(activity: createSampleActivity(name: "Excellent", rating: 4.8))
    try await storageManager.insert(activity: createSampleActivity(name: "Average", rating: 2.5))

    let sorted = try await storageManager.fetchActivitiesSortedByRating()
    #expect(sorted.count == 3)
    #expect(sorted[0].name == "Excellent")
    #expect(sorted[1].name == "Good")
    #expect(sorted[2].name == "Average")
    #expect(sorted[0].rating > sorted[1].rating)
    #expect(sorted[1].rating > sorted[2].rating)
  }

  // MARK: - Delete Tests

  @Test("Delete single activity by model")
  func deleteSingleActivityByModel() async throws {
    let activity = createSampleActivity()
    try await storageManager.insert(activity: activity)

    let beforeDelete = try await storageManager.countAllActivities()
    #expect(beforeDelete == 1)

    // To delete, we need to fetch the model first
    let activities = try await storageManager.fetchActivitiesSortedByDistance()
    guard let activityToDelete = activities.first else {
      Issue.record("No activity found to delete")
      return
    }

    try await storageManager.delete(activity: activityToDelete)

    let afterDelete = try await storageManager.countAllActivities()
    #expect(afterDelete == 0)
  }

  @Test("Delete activity by ID")
  func deleteActivityById() async throws {
    let activityId = UUID()
    let activity = createSampleActivity(id: activityId, name: "To Delete")
    try await storageManager.insert(activity: activity)

    let beforeDelete = try await storageManager.countAllActivities()
    #expect(beforeDelete == 1)

    try await storageManager.delete(with: activityId)

    let afterDelete = try await storageManager.countAllActivities()
    #expect(afterDelete == 0)
  }

  @Test("Delete non-existent activity by ID")
  func deleteNonExistentActivityById() async throws {
    // Try to delete an ID that doesn't exist (should not throw)
    let nonExistentId = UUID()
    try await storageManager.delete(with: nonExistentId)

    let count = try await storageManager.countAllActivities()
    #expect(count == 0)
  }

  @Test("Delete all activities")
  func deleteAllActivities() async throws {
    // Insert multiple activities
    try await storageManager.insert(activity: createSampleActivity(name: "Activity 1"))
    try await storageManager.insert(activity: createSampleActivity(name: "Activity 2"))
    try await storageManager.insert(activity: createSampleActivity(name: "Activity 3"))

    let beforeDelete = try await storageManager.countAllActivities()
    #expect(beforeDelete == 3)

    try await storageManager.deleteAll()

    let afterDelete = try await storageManager.countAllActivities()
    #expect(afterDelete == 0)
  }

  // MARK: - Convert Tests (using testHooks)

  @Test("Convert MoofuslistActivity to MoofuslistActivityModel")
  @MainActor
  func convertActivityToModel() async throws {
    let activity = createSampleActivity(
      id: UUID(),
      name: "Test Location",
      distance: 2.5,
      rating: 4.2,
      isFavorite: true
    )

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.id == activity.id)
    #expect(model.name == activity.name)
    #expect(model.address == activity.address)
    #expect(model.category == activity.category)
    #expect(model.city == activity.city)
    #expect(model.desc == activity.desc)
    #expect(model.distance == activity.distance)
    #expect(model.imageNames == activity.imageNames)
    #expect(model.isFavorite == activity.isFavorite)
    #expect(model.latitude == activity.latitude)
    #expect(model.longitude == activity.longitude)
    #expect(model.phoneNumber == activity.phoneNumber)
    #expect(model.rating == activity.rating)
    #expect(model.reviews == activity.reviews)
    #expect(model.somethingInteresting == activity.somethingInteresting)
    #expect(model.state == activity.state)
  }

  @Test("Convert MoofuslistActivity with nil coordinates to Model")
  @MainActor
  func convertActivityWithNilCoordinatesToModel() async throws {
    var activity = createSampleActivity(name: "No Coordinates")
    activity.latitude = nil
    activity.longitude = nil

    let model = await storageManager.testHooks.convert(activity: activity)

    // Nil coordinates should be converted to 0
    #expect(model.latitude == 0)
    #expect(model.longitude == 0)
    #expect(model.name == "No Coordinates")
  }

  @Test("Convert MoofuslistActivityModel to MoofuslistActivity")
  @MainActor
  func convertModelToActivity() async throws {
    let modelId = UUID()
    let model = MoofuslistActivityModel(
      id: modelId,
      address: "789 Test Ave",
      category: "Test Category",
      city: "Test City",
      desc: "Test Description",
      distance: 3.7,
      imageNames: ["image1", "image2"],
      isFavorite: true,
      latitude: 40.7128,
      longitude: -74.0060,
      name: "Test Model Location",
      rating: 4.9,
      reviews: 250,
      phoneNumber: "555-9999",
      somethingInteresting: "Very interesting",
      state: "NY"
    )

    let activity = await storageManager.testHooks.convert(activities: [model]).first

    #expect(activity != nil)
    guard let activity else { return }

    #expect(activity.id == model.id)
    #expect(activity.name == model.name)
    #expect(activity.address == model.address)
    #expect(activity.category == model.category)
    #expect(activity.city == model.city)
    #expect(activity.desc == model.desc)
    #expect(activity.distance == model.distance)
    #expect(activity.imageNames == model.imageNames)
    #expect(activity.isFavorite == model.isFavorite)
    #expect(activity.latitude == model.latitude)
    #expect(activity.longitude == model.longitude)
    #expect(activity.phoneNumber == model.phoneNumber)
    #expect(activity.rating == model.rating)
    #expect(activity.reviews == model.reviews)
    #expect(activity.somethingInteresting == model.somethingInteresting)
    #expect(activity.state == model.state)
  }

  @Test("Convert multiple MoofuslistActivityModels to MoofuslistActivities")
  @MainActor
  func convertMultipleModelsToActivities() async throws {
    let models = [
      MoofuslistActivityModel(
        id: UUID(),
        address: "111 First St",
        category: "Restaurant",
        city: "City1",
        desc: "Description 1",
        distance: 1.0,
        imageNames: ["food"],
        isFavorite: false,
        latitude: 37.7749,
        longitude: -122.4194,
        name: "Restaurant 1",
        rating: 4.5,
        reviews: 100,
        phoneNumber: "555-0001",
        somethingInteresting: "Great food",
        state: "CA"
      ),
      MoofuslistActivityModel(
        id: UUID(),
        address: "222 Second Ave",
        category: "Park",
        city: "City2",
        desc: "Description 2",
        distance: 2.0,
        imageNames: ["tree"],
        isFavorite: true,
        latitude: 40.7128,
        longitude: -74.0060,
        name: "Park 1",
        rating: 4.8,
        reviews: 200,
        phoneNumber: "555-0002",
        somethingInteresting: "Beautiful scenery",
        state: "NY"
      ),
      MoofuslistActivityModel(
        id: UUID(),
        address: "333 Third Blvd",
        category: "Museum",
        city: "City3",
        desc: "Description 3",
        distance: 3.0,
        imageNames: ["building"],
        isFavorite: false,
        latitude: 41.8781,
        longitude: -87.6298,
        name: "Museum 1",
        rating: 4.7,
        reviews: 150,
        phoneNumber: "555-0003",
        somethingInteresting: "Historic artifacts",
        state: "IL"
      )
    ]

    let activities = await storageManager.testHooks.convert(activities: models)

    #expect(activities.count == 3)

    for (index, activity) in activities.enumerated() {
      let model = models[index]
      #expect(activity.id == model.id)
      #expect(activity.name == model.name)
      #expect(activity.address == model.address)
      #expect(activity.category == model.category)
      #expect(activity.city == model.city)
      #expect(activity.distance == model.distance)
      #expect(activity.isFavorite == model.isFavorite)
      #expect(activity.rating == model.rating)
    }
  }

  @Test("Convert empty array of models")
  func convertEmptyArrayOfModels() async throws {
    let emptyModels: [MoofuslistActivityModel] = []
    let activities = await storageManager.testHooks.convert(activities: emptyModels)

    #expect(activities.isEmpty)
  }

  @Test("Convert activity with special characters")
  @MainActor
  func convertActivityWithSpecialCharacters() async throws {
    var activity = createSampleActivity()
    activity.name = "Café & Restaurant™"
    activity.desc = "Great food with 🍕 pizza!"
    activity.address = "123 O'Brien St, Apt #5"
    activity.somethingInteresting = "They have a \"secret\" menu 😊"

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.name == "Café & Restaurant™")
    #expect(model.desc == "Great food with 🍕 pizza!")
    #expect(model.address == "123 O'Brien St, Apt #5")
    #expect(model.somethingInteresting == "They have a \"secret\" menu 😊")
  }

  @Test("Convert activity with extreme coordinate values")
  @MainActor
  func convertActivityWithExtremeCoordinates() async throws {
    var activity = createSampleActivity()
    activity.latitude = 90.0  // North Pole
    activity.longitude = 180.0  // International Date Line

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.latitude == 90.0)
    #expect(model.longitude == 180.0)
  }

  @Test("Convert activity with zero distance and rating")
  func convertActivityWithZeroValues() async throws {
    let activity = createSampleActivity(distance: 0.0, rating: 0.0)

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.distance == 0.0)
    #expect(model.rating == 0.0)
  }

  @Test("Convert activity with large review count")
  @MainActor
  func convertActivityWithLargeReviewCount() async throws {
    var activity = createSampleActivity()
    activity.reviews = 999999

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.reviews == 999999)
  }

  @Test("Convert activity with empty image names array")
  @MainActor
  func convertActivityWithEmptyImageNames() async throws {
    var activity = createSampleActivity()
    activity.imageNames = []

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.imageNames.isEmpty)
  }

  @Test("Convert activity with multiple image names")
  @MainActor
  func convertActivityWithMultipleImageNames() async throws {
    var activity = createSampleActivity()
    activity.imageNames = ["image1", "image2", "image3", "image4", "image5"]

    let model = await storageManager.testHooks.convert(activity: activity)

    #expect(model.imageNames.count == 5)
    #expect(model.imageNames == ["image1", "image2", "image3", "image4", "image5"])
  }

  @Test("Round-trip conversion preserves data")
  @MainActor
  func roundTripConversionPreservesData() async throws {
    let originalActivity = createSampleActivity(
      id: UUID(),
      name: "Original Activity",
      distance: 5.5,
      rating: 4.3,
      isFavorite: true
    )

    // Convert to model
    let model = await storageManager.testHooks.convert(activity: originalActivity)

    // Convert back to activity
    let convertedActivity = await storageManager.testHooks.convert(activities: [model]).first

    #expect(convertedActivity != nil)
    guard let convertedActivity else { return }

    #expect(convertedActivity.id == originalActivity.id)
    #expect(convertedActivity.name == originalActivity.name)
    #expect(convertedActivity.address == originalActivity.address)
    #expect(convertedActivity.category == originalActivity.category)
    #expect(convertedActivity.city == originalActivity.city)
    #expect(convertedActivity.desc == originalActivity.desc)
    #expect(convertedActivity.distance == originalActivity.distance)
    #expect(convertedActivity.imageNames == originalActivity.imageNames)
    #expect(convertedActivity.isFavorite == originalActivity.isFavorite)
    #expect(convertedActivity.latitude == originalActivity.latitude)
    #expect(convertedActivity.longitude == originalActivity.longitude)
    #expect(convertedActivity.phoneNumber == originalActivity.phoneNumber)
    #expect(convertedActivity.rating == originalActivity.rating)
    #expect(convertedActivity.reviews == originalActivity.reviews)
    #expect(convertedActivity.somethingInteresting == originalActivity.somethingInteresting)
    #expect(convertedActivity.state == originalActivity.state)
  }

  // MARK: - Edge Cases

  @Test("Insert activity with nil latitude and longitude")
  @MainActor
  func insertActivityWithNilCoordinates() async throws {
    var activity = createSampleActivity()
    activity.latitude = nil
    activity.longitude = nil

    try await storageManager.insert(activity: activity)

    let activities = try await storageManager.fetchAllActivities()
    #expect(activities.count == 1)
    // The model converts nil to 0
    let fetched = try await storageManager.fetchActivitiesSortedByDistance()
    #expect(fetched.first?.latitude == 0)
    #expect(fetched.first?.longitude == 0)
  }

  @Test("Insert activity with favorite flag")
  @MainActor
  func insertActivityWithFavoriteFlag() async throws {
    let activity = createSampleActivity(isFavorite: true)
    try await storageManager.insert(activity: activity)

    let activities = try await storageManager.fetchAllActivities()
    #expect(activities.count == 1)
    #expect(activities.first?.isFavorite == true)
  }

  @Test("Empty database operations")
  func emptyDatabaseOperations() async throws {
    let count = try await storageManager.countAllActivities()
    #expect(count == 0)

    let activities = try await storageManager.fetchAllActivities()
    #expect(activities.isEmpty)

    let sortedByDistance = try await storageManager.fetchActivitiesSortedByDistance()
    #expect(sortedByDistance.isEmpty)

    let sortedByRating = try await storageManager.fetchActivitiesSortedByRating()
    #expect(sortedByRating.isEmpty)

    // Delete all on empty database should work
    try await storageManager.deleteAll()
  }

  // MARK: - Helper Methods

  /// Creates an in-memory model container for testing
  func createTestContainer() throws -> ModelContainer {
    let schema = Schema([MoofuslistActivityModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [configuration])
  }

  /// Creates a sample MoofuslistActivity for testing
  func createSampleActivity(
    id: UUID = UUID(),
    name: String = "Test Activity",
    distance: Double = 1.5,
    rating: Double = 4.5,
    isFavorite: Bool = false
  ) -> MoofuslistActivity {
    return MoofuslistActivity(
      id: id,
      address: "123 Test St",
      category: "Test Category",
      city: "Test City",
      desc: "Test description",
      distance: distance,
      imageNames: ["test.image"],
      isFavorite: isFavorite,
      latitude: 37.7749,
      longitude: -122.4194,
      name: name,
      phoneNumber: "555-0100",
      rating: rating,
      reviews: 100,
      somethingInteresting: "Something interesting",
      state: "CA"
    )
  }
}
// swiftlint:enable file_length function_body_length type_body_length
