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
//      MoofuslistView()
      //          LocationManagerView()
                JunkView()
    }
  }

}

extension Container {
  var locationManager: Factory<LocationManager> {
    self { LocationManager() }.singleton
  }
  var moofuslistSource: Factory<MoofuslistSource> {
    self { MoofuslistSource() }.singleton
  }
  @MainActor var moofuslistViewModel: Factory<MoofuslistViewModel> {
    self { @MainActor in MoofuslistViewModel() }
  }
}
