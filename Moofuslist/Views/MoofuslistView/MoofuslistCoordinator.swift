//
//  MoofuslistCoordinator.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class MoofuslistCoordinator {
  enum Route: Hashable {
    case content
    case detail
    case sidebar
  }

  var splitViewColum: NavigationSplitViewColumn

  init() {
    self.splitViewColum = .sidebar
  }

  func navigate(to route: Route) {
    switch route {
    case .content:
      splitViewColum = .content
    case .detail:
      splitViewColum = .detail
    case .sidebar:
      splitViewColum = .sidebar
    }
  }
}
