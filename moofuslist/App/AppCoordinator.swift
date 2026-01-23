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

  let continuation: AsyncStream<Route>.Continuation
  let stream: AsyncStream<Route>
  var splitViewColum: NavigationSplitViewColumn

  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Route.self)
    self.splitViewColum = .sidebar
  }

  func navigate(to route: Route) {
    switch route {
    case .content:
      print("ljw selecting content")
      continuation.yield(.content)
      splitViewColum = .content
    case .detail:
      print("ljw selecting detail")
      continuation.yield(.detail)
      splitViewColum = .detail
    case .sidebar:
      print("ljw selecting sidebar")
      continuation.yield(.sidebar)
      splitViewColum = .sidebar
    }
  }
}
