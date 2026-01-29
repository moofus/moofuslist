//
//  moofuslistApp.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/22/25.
//

import FactoryKit
import SwiftData
import SwiftUI

@main
struct moofuslistApp: App {
  var body: some Scene {
    WindowGroup {
      MoofuslistView()
    }
  }
}

extension Container {
  @MainActor var moofuslistCoordinator: Factory<MoofuslistCoordinator> {
    self { @MainActor in MoofuslistCoordinator() }.singleton
  }
  var aiManager: Factory<AIManager> {
    self { AIManager() }.singleton
  }
  var locationManager: Factory<LocationManager> {
    self { LocationManager() }.singleton
  }
  var storageManager: ParameterFactory<ModelContainer, StorageManager> {
    self { StorageManager(container: $0) }
  }
  var moofuslistSource: Factory<MoofuslistSource> {
    self { MoofuslistSource() }.singleton
  }
  @MainActor var moofuslistViewModel: Factory<MoofuslistViewModel> {
    self { @MainActor in MoofuslistViewModel() }.singleton
  }
}
