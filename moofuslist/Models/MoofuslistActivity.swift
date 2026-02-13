//
//  MoofuslistActivity.swift
//  moofuslist
//
//  Created by Lamar Williams III on 2/13/26.
//

import Foundation
import MapKit

struct MoofuslistActivity: Hashable, Identifiable {
  // keep insync with MoofuslistActivityModel
  var id = UUID()
  var address: String
  var category: String
  var city: String
  var desc: String
  var distance: Double
  var imageNames: [String]
  var isFavorite: Bool
  var mapItem: MKMapItem? // Note: latitude, longitude is saved in storage
  var name: String
  var rating: Double
  var reviews: Int
  var phoneNumber: String
  var somethingInteresting: String
  var state: String
}
