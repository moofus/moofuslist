//
//  MoofuslistApp.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/22/25.
//

import CoreLocation
import FactoryKit
import SwiftData
import SwiftUI

@main
struct MoofuslistApp: App {
  var body: some Scene {
    WindowGroup {
      MoofuslistView()
    }
  }
}

extension Container {
  var aiManager: Factory<AIManager> {
    self { AIManager() }.singleton
  }
  var liveUpdates: Factory<any LocationUpdateStream> {
    self { CLLocationUpdate.liveUpdates() }
  }
  var locationManager: Factory<LocationManager> {
    self { LocationManager() }.singleton
  }
  @MainActor var moofuslistCoordinator: Factory<MoofuslistCoordinator> {
    self { @MainActor in MoofuslistCoordinator() }.singleton
  }
  var storageManager: ParameterFactory<ModelContainer, StorageManager> {
    self { StorageManager(modelContainer: $0) }
  }
  var moofuslistSource: Factory<MoofuslistSource> {
    self { MoofuslistSource() }.singleton
  }
  @MainActor var moofuslistViewModel: Factory<MoofuslistViewModel> {
    self { @MainActor in MoofuslistViewModel() }.singleton
  }
}
