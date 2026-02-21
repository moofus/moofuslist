//
//  TimedAction.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/14/26.
//

import SwiftUI
import Combine

final class TimedAction: ObservableObject {
  private(set) var count = UInt.zero
  private var maxCount = UInt.max
  private var task: Task<Void, Never>?

  deinit {
    task?.cancel()
    task = nil
  }

  func start(
    count maxCount: UInt = UInt.max,
    sleepTimeInSeconds: UInt = 2,
    action: @escaping () -> (),
    errorHandler: ((Error) -> Void)? = nil
  ) {
    self.maxCount = maxCount
    count = UInt.zero

    stop()

    task = Task {
      repeat {
        do {
          try Task.checkCancellation()
          action()
          count += 1
          try await Task.sleep(nanoseconds: UInt64(sleepTimeInSeconds) * 1_000_000_000)
        } catch {
          errorHandler?(error)
          break
        }
      } while count < maxCount
    }
  }

  func stop() {
    task?.cancel()
    task = nil
  }
}
