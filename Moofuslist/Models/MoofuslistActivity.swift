//
//  MoofuslistActivity.swift
//  moofuslist
//
//  Created by Lamar Williams III on 2/13/26.
//

import Foundation
@preconcurrency import MapKit

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
  var latitude: Double?
  var longitude: Double?
  var name: String
  var phoneNumber: String
  var rating: Double
  var reviews: Int
  var somethingInteresting: String
  var state: String

  func mapItem() async -> MKMapItem? {
    guard let latitude, let longitude else {
      return nil
    }
    let location = CLLocation(latitude: latitude, longitude: longitude)
    return try? await MKReverseGeocodingRequest(location: location)?.mapItems.first
  }
}

let globalActivities = [
  MoofuslistActivity(
    id: UUID(),
    address: "3434 main Street Oakland, CA",
    category: "Park",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 1.5,
    imageNames: ["house", "car"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "name1",
    phoneNumber: "510-320-8384",
    rating: 4.7,
    reviews: 42,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "3434 main Street Oakland, CA",
    category: "Park",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 7.9,
    imageNames: ["house", "car"],
    isFavorite: true,
    latitude: nil,
    longitude: nil,
    name: "name2",
    phoneNumber: "510-320-8384",
    rating: 3.9,
    reviews: 83,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "123 Main St",
    category: "Restaurants",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 0.3,
    imageNames: ["fork.knife"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "Downtown Pizza Co.",
    phoneNumber: "510-320-8384",
    rating: 4.8,
    reviews: 245,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "Park Avenue",
    category: "Parks",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 0.5,
    imageNames: ["tree.fill"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "Central Park Trails",
    phoneNumber: "510-320-8384",
    rating: 4.6,
    reviews: 189,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "456 Art Blvd",
    category: "Museums",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 1.2,
    imageNames: ["building.2.fill"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "Modern Art Gallery",
    phoneNumber: "510-320-8384",
    rating: 4.7,
    reviews: 156,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "789 Fun St",
    category: "Entertainment",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 0.8,
    imageNames: ["popcorn.fill"],
    isFavorite: true,
    latitude: nil,
    longitude: nil,
    name: "Comedy Club Live",
    phoneNumber: "510-320-8384",
    rating: 4.5,
    reviews: 203,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "Shopping District",
    category: "Shopping",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 1.1,
    imageNames: ["bag.fill"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "Vintage Market Hall",
    phoneNumber: "510-320-8384",
    rating: 4.8,
    reviews: 245,
    somethingInteresting: "somethingInteresting",
    state: "State"
  ),
  MoofuslistActivity(
    id: UUID(),
    address: "Downtown Heights",
    category: "Nightlife",
    city: "Oakland",
    desc: "This place is beautiful",
    distance: 0.6,
    imageNames: ["moon.stars.fill"],
    isFavorite: false,
    latitude: nil,
    longitude: nil,
    name: "The Rooftop Bar",
    phoneNumber: "510-320-8384",
    rating: 4.8,
    reviews: 245,
    somethingInteresting: "somethingInteresting",
    state: "State"
  )
]
