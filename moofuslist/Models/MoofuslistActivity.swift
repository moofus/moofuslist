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
  // keep insync with MoofuslistViewModel.Activity
  var id: UUID
  var address: String
  var category: String
  var city: String
  var desc: String
  var distance: Double
  var imageNames: [String]
  var isFavorite = false
  var latitude: Double
  var longitude: Double
  var name: String
  var rating: Double
  var reviews: Int
  var phoneNumber: String
  var somethingInteresting: String
  var state: String

  init(
    id: UUID,
    address: String,
    category: String,
    city: String,
    desc: String,
    distance: Double,
    imageNames: [String],
    isFavorite: Bool = false,
    latitude: Double,
    longitude: Double,
    name: String,
    rating: Double,
    reviews: Int,
    phoneNumber: String,
    somethingInteresting: String,
    state: String
  ) {
    self.id = id
    self.address = address
    self.category = category
    self.city = city
    self.desc = desc
    self.distance = distance
    self.imageNames = imageNames
    self.isFavorite = isFavorite
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.rating = rating
    self.reviews = reviews
    self.phoneNumber = phoneNumber
    self.somethingInteresting = somethingInteresting
    self.state = state
  }
}
