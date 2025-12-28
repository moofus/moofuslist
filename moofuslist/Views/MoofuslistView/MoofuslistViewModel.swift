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

  private(set) var errorDescription = ""
  private(set) var errorRecoverySuggestion = ""
  var haveError = false

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
    Task { await handleSource() }
  }

  private func handleSource() async {
    for await state in source.stream {
      switch state {
      case .error(let error):
        errorDescription = error.errorDescription ?? "Error"
        errorRecoverySuggestion = error.recoverySuggestion ?? "Try again later."
        haveError = true
      case .initial:
        break
      }
    }
  }
}
