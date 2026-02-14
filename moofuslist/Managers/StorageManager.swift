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

  public func fetch(with id: UUID) async throws -> MoofuslistActivityModel? {
      let predicate = #Predicate<MoofuslistActivityModel> { $0.id == id }
      var fetchDescriptor = FetchDescriptor<MoofuslistActivityModel>(predicate: predicate)
      fetchDescriptor.fetchLimit = 1
      let items = try modelContext.fetch(fetchDescriptor)
      return items.first
  }

  public func insert(activities: [MoofuslistActivityModel]) async throws {
    try modelContext.transaction {
      for activity in activities {
        modelContext.insert(activity)
      }
    }
    try modelContext.save()
  }

  public func insert(activity: MoofuslistActivityModel) async throws {
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

  public func fetchAllActivities() async throws -> [MoofuslistActivityModel] {
    let descriptor = FetchDescriptor<MoofuslistActivityModel>()
    return try modelContext.fetch(descriptor)
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
