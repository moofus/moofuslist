//
//  TimedActions.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/14/26.
//


import SwiftUI

class TimedAction {
  private var task: Task<(), Never>?
  private(set) var count = UInt.zero
  private var maxCount: UInt = 1

  func start(count maxCount: UInt = UInt.max, sleepTimeInSeconds: UInt = 1, action: @escaping () -> ()) {
    self.maxCount = maxCount
    count = UInt.zero
    
    task = Task {
      repeat {
        try? await Task.sleep(for: .seconds(sleepTimeInSeconds))
        count += 1
        action()
      } while count < maxCount && !Task.isCancelled
    }
  }

  func stop() {
    task?.cancel()
    task = nil
  }
}
