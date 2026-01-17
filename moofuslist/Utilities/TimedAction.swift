//
//  TimedActions.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/14/26.
//

import SwiftUI

class TimedAction {
  private(set) var count = UInt.zero
  private var maxCount: UInt = 1
  private var task: Task<Void, Never>?

  deinit {
    stop()
  }

  func start(count maxCount: UInt = UInt.max, sleepTimeInSeconds: UInt = 1, action: @escaping () -> (), errorHandler: ((Error) -> Void)? = nil) {
    self.maxCount = maxCount
    count = UInt.zero

    task = Task(priority: nil) {
      repeat {
        do {
          try Task.checkCancellation()
          try await Task.sleep(nanoseconds: UInt64(sleepTimeInSeconds) * 1_000_000_000)
          count += 1
          action()
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
