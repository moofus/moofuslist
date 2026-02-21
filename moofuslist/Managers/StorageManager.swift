//
//  StorageManager.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/25/26.
//

import Foundation
import SwiftData

@ModelActor
actor StorageManager {

  public func insert(activities: [MoofuslistActivityModel]) async throws {
    try modelContext.transaction {
      for activity in activities {
        modelContext.insert(activity)
      }
    }
    try modelContext.save()
  }

  public func insert(activity: MoofuslistActivity) async throws {
    let activity = await convert(activity: activity)
    modelContext.insert(activity)
    try modelContext.save()
  }

  public func delete(activity: MoofuslistActivityModel) async throws {
    modelContext.delete(activity)
    try modelContext.save()
  }

  public func delete(with id: UUID) async throws {
    if let activity = try await fetch(with: id) {
      try await delete(activity: activity)
    }
  }

  public func deleteAll() async throws {
    try modelContext.delete(model: MoofuslistActivityModel.self)
    try modelContext.save()
  }

  public func fetchAllActivities() async throws -> [MoofuslistActivity] {
    let descriptor = FetchDescriptor<MoofuslistActivityModel>()
    let activities = try modelContext.fetch(descriptor)
    return convert(activities: activities)
  }

  public func countAllActivities() async throws -> Int {
    let descriptor = FetchDescriptor<MoofuslistActivityModel>()
    return try modelContext.fetchCount(descriptor)
  }

  public func fetchActivitiesSortedByDistance() async throws -> [MoofuslistActivityModel] {
    let descriptor = FetchDescriptor<MoofuslistActivityModel>(
      sortBy: [SortDescriptor(\.distance)]
    )
    return try modelContext.fetch(descriptor)
  }

  public func fetchActivitiesSortedByRating() async throws -> [MoofuslistActivityModel] {
    let descriptor = FetchDescriptor<MoofuslistActivityModel>(
      sortBy: [SortDescriptor(\.rating, order: .reverse)]
    )
    return try modelContext.fetch(descriptor)
  }
}

extension StorageManager {
  private func convert(activities: [MoofuslistActivityModel]) -> [MoofuslistActivity] {
    var result = [MoofuslistActivity]()
    for activity in activities {
      let newActivity = MoofuslistActivity(
        id: activity.id,
        address: activity.address,
        category: activity.category,
        city: activity.city,
        desc: activity.desc,
        distance: activity.distance,
        imageNames: activity.imageNames,
        isFavorite: activity.isFavorite,
        latitude: activity.latitude,
        longitude: activity.longitude,
        name: activity.name,
        phoneNumber: activity.phoneNumber,
        rating: activity.rating,
        reviews: activity.reviews,
        somethingInteresting: activity.somethingInteresting,
        state: activity.state
      )
      result.append(newActivity)
    }
    return result
  }

  private func convert(activity: MoofuslistActivity) async -> MoofuslistActivityModel {
    MoofuslistActivityModel(
      id: activity.id,
      address: activity.address,
      category: activity.category,
      city: activity.city,
      desc: activity.desc,
      distance: activity.distance,
      imageNames: activity.imageNames,
      isFavorite: activity.isFavorite,
      latitude: activity.latitude ?? 0,
      longitude: activity.longitude ?? 0,
      name: activity.name,
      rating: activity.rating,
      reviews: activity.reviews,
      phoneNumber: activity.phoneNumber,
      somethingInteresting: activity.somethingInteresting,
      state: activity.state
    )
  }

  private func fetch(with id: UUID) async throws -> MoofuslistActivityModel? {
    let predicate = #Predicate<MoofuslistActivityModel> { $0.id == id }
    var fetchDescriptor = FetchDescriptor<MoofuslistActivityModel>(predicate: predicate)
    fetchDescriptor.fetchLimit = 1
    let items = try modelContext.fetch(fetchDescriptor)
    return items.first
  }
}
