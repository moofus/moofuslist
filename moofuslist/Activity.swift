//
//  Activity.swift
//  Tracker
//
//  Created by Lamar Williams III on 4/14/25.
//

import Foundation

struct Activity: Comparable, Identifiable {
  static func < (lhs: Activity, rhs: Activity) -> Bool {
    lhs.id < rhs.id
  }

  let id = UUID()
  let date: Date
  let name: String
  var sets : [Int] = []
}

struct ActivityList: Identifiable {
  let id: Date
  let activities: [Activity]
  var formattedDate: String {
    var tmpC = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    let dateC = Calendar.current.dateComponents([.year, .month, .day], from: id)
    if tmpC.year! == dateC.year! && tmpC.month! == dateC.month! && tmpC.day! == dateC.day! {
      return "Today"
    }
    tmpC = Calendar.current.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(-86400))
    if tmpC.year! == dateC.year! && tmpC.month! == dateC.month! && tmpC.day! == dateC.day! {
      return "Yesterday"
    }
    return DateFormatter.localizedString(from: id as Date, dateStyle: .medium, timeStyle: .none)
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
