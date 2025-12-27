//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation

final actor MoofuslistSource {

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
  }

}

extension MoofuslistSource {
  func findActivities() async {
    print("sleeping")
    try? await Task.sleep(nanoseconds: 5000000000)
    print("sleeping end")
  }
}
