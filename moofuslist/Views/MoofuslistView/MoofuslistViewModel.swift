//
//  MoofuslistViewModel.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 4/16/25.
//

import Foundation

@Observable
class MoofuslistViewModel {
  var activities: [Activity] = []
  var activityList: [ActivityList] = []

  private let sourceStream: MoofuslistSource.Stream
  private let sourceContinuation: MoofuslistSource.Stream.Continuation
  private let viewSource: MoofuslistSource

  init(
    stream: (MoofuslistSource.Stream, MoofuslistSource.Stream.Continuation),
    viewSource: MoofuslistSource
  ) {
    sourceStream = stream.0
    sourceContinuation = stream.1
    self.viewSource = viewSource

    Task.detached { [weak self] in
      await self?.handleMessages()
    }
  }
}

extension MoofuslistViewModel {
  private func handleMessages() async {
    for await message in sourceStream {
      Task { @MainActor [weak self] in
        guard let self else { return }

        switch message {
        case .idle: print("idle")
        }
      }
    }
  }
}
