//
//  MoofuslistViewModel.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit

@MainActor
@Observable
class MoofuslistViewModel {
  @ObservationIgnored
  @Injected(\.moofuslistSource) var source: MoofuslistSource

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
  }
}
