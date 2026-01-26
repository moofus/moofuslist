//
//  moofuslistApp.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/22/25.
//

import FactoryKit
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
  @MainActor var appCoordinator: Factory<AppCoordinator> {
    self { @MainActor in AppCoordinator() }.singleton
  }
  var aiManager: Factory<AIManager> {
    self { AIManager() }.singleton
  }
  var locationManager: Factory<LocationManager> {
    self { LocationManager() }.singleton
  }
  var storageManager: Factory<StorageManager> {
    self { StorageManager() }.singleton
  }
  var moofuslistSource: Factory<MoofuslistSource> {
    self { MoofuslistSource() }.singleton
  }
  @MainActor var moofuslistViewModel: Factory<MoofuslistViewModel> {
    self { @MainActor in MoofuslistViewModel() }
  }
}
