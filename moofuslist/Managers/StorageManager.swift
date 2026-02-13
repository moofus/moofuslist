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
  public func insert(activity: MoofuslistActivityModel) async throws {
    modelContext.insert(activity)
    try modelContext.save()
  }

  public func delete(activity: MoofuslistActivityModel) async throws {
    modelContext.delete(activity)
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
