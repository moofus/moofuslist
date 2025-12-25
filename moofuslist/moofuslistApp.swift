//
//  moofuslistApp.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/22/25.
//

import SwiftUI

@main
struct moofuslistApp: App {
  @State var locationManager = LocationManager()

  var body: some Scene {
        WindowGroup {
//          MoofuslistView()
//            .environment(locationManager)
          JunkView()
            .environment(locationManager)
        }
    }
}
