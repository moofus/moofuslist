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

  private let continuation: AsyncStream<Route>.Continuation
  let stream: AsyncStream<Route>
  var splitViewColum: NavigationSplitViewColumn

  init() {
    (stream, continuation) = AsyncStream<Route>.makeStream()
    self.splitViewColum = .sidebar
  }

  func navigate(to route: Route) {
    switch route {
    case .content:
      continuation.yield(.content)
      splitViewColum = .content
    case .detail:
      continuation.yield(.detail)
      splitViewColum = .detail
    case .sidebar:
      continuation.yield(.sidebar)
      splitViewColum = .sidebar
    }
  }
}
