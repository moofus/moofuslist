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

