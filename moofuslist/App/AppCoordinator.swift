//
//  AppCoordinator.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/8/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class AppCoordinator {
  enum Route: Hashable {
    case content
    case detail
    case sidebar
  }

  init() {
    self.splitViewColum = .sidebar
  }

  var splitViewColum: NavigationSplitViewColumn

  func navigate(to route: Route) {
    switch route {
    case .content: splitViewColum = .content
    case .detail: splitViewColum = .detail
    case .sidebar: splitViewColum = .sidebar
    }
  }
}
