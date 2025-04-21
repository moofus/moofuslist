//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 4/18/25.
//

import Foundation

class MoofuslistSource {

  typealias Stream = AsyncStream<State>

  enum State: Sendable {
    case idle
  }

  let continuation: AsyncStream<State>.Continuation

  init(continuation: AsyncStream<State>.Continuation) {
    self.continuation = continuation

    Task.detached { [weak self] in
      try? await Task.sleep(seconds: 5)
      self?.send(.idle)
    }
  }
}

extension MoofuslistSource {
  private func send(_ state: State) {
    continuation.yield(state)
  }
}


#if DEBUG
private let tmpDate = Date()
let activities = [
  Activity(date: tmpDate, name: "Duck Walk", sets: [1, 2, 3]),
  Activity(date: tmpDate, name: "Shoulders"),
  Activity(date: tmpDate.addingTimeInterval(-86400), name: "Speed 60"),
  Activity(date: tmpDate.addingTimeInterval(-86400), name: "Bend Back"),
  Activity(date: tmpDate.addingTimeInterval(-86400 * 2), name: "Pull Ups"),
  Activity(date: tmpDate.addingTimeInterval(-86400 * 2), name: "Leg Lifts"),
]

let activityList: [ActivityList] =  {
  var activityList = [ActivityList]()
  var tmpActivities = [Activity]()
  var lastDate = Date.distantPast // this date should not exist in data

  // group dates together assuming activites sorted on date
  for a in activities {
    if lastDate == a.date {
      tmpActivities.append(a)
    } else {
      if lastDate != Date.distantPast {
        activityList.append(ActivityList(id: lastDate, activities: tmpActivities))
        tmpActivities.removeAll()
      }
      lastDate = a.date
      tmpActivities.append(a)
    }
  }

  if !tmpActivities.isEmpty {
    activityList.append(ActivityList(id: lastDate, activities: tmpActivities))
  }

  return activityList
}()
#endif
