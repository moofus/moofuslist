//
//  MoofuslistActivity.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/25/26.
//

import Foundation
import MapKit
import SwiftData

@Model
class MoofuslistActivity: Hashable, Identifiable {
  var id = UUID()
  var address: String
  var category: String
  var city: String
  var desc: String
  var distance: Double
  var imageNames: [String]
  var isFavorite = false
  @Transient
  var mapItem: MKMapItem?
  var name: String
  var rating: Double
  var reviews: Int
  var somethingInteresting: String
  var state: String

  init(
    address: String,
    category: String,
    city: String,
    desc: String,
    distance: Double,
    imageNames: [String],
    isFavorite: Bool = false,
    mapItem: MKMapItem? = nil,
    name: String,
    rating: Double,
    reviews: Int,
    somethingInteresting: String,
    state: String
  ) {
    self.address = address
    self.category = category
    self.city = city
    self.desc = desc
    self.distance = distance
    self.imageNames = imageNames
    self.isFavorite = isFavorite
    self.mapItem = mapItem
    self.name = name
    self.rating = rating
    self.reviews = reviews
    self.somethingInteresting = somethingInteresting
    self.state = state
  }
}
