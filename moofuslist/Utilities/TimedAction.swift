//
//  TimedActions.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/14/26.
//

import SwiftUI

class TimedAction {
  private(set) var count = UInt.zero
  private var maxCount = UInt.max
  private var task: Task<Void, Never>?

  func start(
    count maxCount: UInt = UInt.max,
    sleepTimeInSeconds: UInt = 2,
    action: @escaping () -> (),
    errorHandler: ((Error) -> Void)? = nil
  ) {
    self.maxCount = maxCount
    count = UInt.zero

    print("\(Date()) calling stop")
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
    print("stop")
    task?.cancel()
    task = nil
  }
}
