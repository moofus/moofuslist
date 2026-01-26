//
//  StorageManager.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/25/26.
//

import Foundation
import SwiftData

actor StorageManager {
  private let container: ModelContainer
  private let context: ModelContext

  init() {
    do {
      let container = try ModelContainer(for: MoofuslistActivity.self)
      self.container = container
      self.context = ModelContext(container)
    } catch {
      print("error=\(error)")
      assertionFailure()
      fatalError("Failed to initialize StorageManager's ModelContainer")
    }
  }

  public func insert(activity: MoofuslistActivity) async throws {
    context.insert(activity)
    try context.save()
  }

  public func delete(activity: MoofuslistActivity) async throws {
    context.delete(activity)
    try context.save()
  }

  public func fetchAllActivities() async throws -> [MoofuslistActivity] {
    let descriptor = FetchDescriptor<MoofuslistActivity>()
    return try context.fetch(descriptor)
  }

  public func fetchActivitiesSortedByDistance() async throws -> [MoofuslistActivity] {
    let descriptor = FetchDescriptor<MoofuslistActivity>(
      sortBy: [SortDescriptor(\.distance)]
    )
    return try context.fetch(descriptor)
  }

  public func fetchActivitiesSortedByRating() async throws -> [MoofuslistActivity] {
    let descriptor = FetchDescriptor<MoofuslistActivity>(
      sortBy: [SortDescriptor(\.rating, order: .reverse)]
    )
    return try context.fetch(descriptor)
  }
}
