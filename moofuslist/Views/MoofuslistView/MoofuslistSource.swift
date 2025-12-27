//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit

final actor MoofuslistSource {
  @Injected(\.locationManager) var locationManager: LocationManager

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
    Task {
      await handleLocationManager()
    }
  }

  private func handleLocationManager() async {
    for await location in locationManager.stream {
      print(location)
    }
  }
}

extension MoofuslistSource {
  func findActivities() async {
    print("starting")
    await locationManager.start()
    print("sleeping end")
  }
}
