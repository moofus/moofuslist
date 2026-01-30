//
//  MoofuslistViewModel.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit
import MapKit
import os
import SwiftUI

@MainActor
@Observable
final class MoofuslistViewModel {
  // keep insync with MoofuslistActivity
  struct Activity: Hashable, Identifiable {
    var id = UUID()
    var address: String
    var category: String
    var city: String
    var desc: String
    var distance: Double
    var imageNames: [String]
    var isFavorite = false
    var mapItem: MKMapItem?
    var name: String
    var rating: Double
    var reviews: Int
    var phoneNumber: String
    var somethingInteresting: String
    var state: String
  }

  @ObservationIgnored @Injected(\.moofuslistSource) private var source: MoofuslistSource

  var activities: [Activity] = []
  private(set) var errorDescription: String = ""
  private(set) var errorRecoverySuggestion: String = ""
  var haveError: Bool = false
  var inputError: Bool = false
  private(set) var loading: Bool = false
  private(set) var location = CLLocation()
  private(set) var mapItem: MKMapItem? = nil
  var mapPosition: MapCameraPosition = .automatic
  private(set) var processing: Bool = false
  private(set) var searchedCityState: String = ""
  var selectedActivity: Activity? = nil

  init() {
    Task { @MainActor in
      await handleSource()
    }
  }
}

// MARK: Methods
extension MoofuslistViewModel {
  @MainActor
  private func handleSource() async {
    for await message in source.stream {
      print(message)
      switch message {
      case .changeFavorite(let id): changeFavorite(id: id)
      case let .error(description, recoverySuggestion):
        errorDescription = description
        errorRecoverySuggestion = recoverySuggestion
      case .initialize: initialize()
      case .inputError: inputError = true
      case .loaded(let loading): self.loading = loading
      case let .loading(activities, loading, processing):
        self.activities = activities
        self.loading = loading
        self.processing = processing
      case .loadMapItems: await loadMapItems()
      case .mapItem(let mapItem):
        processeMapItem(mapItem)
      case .processing: processing = true
      case .selectActivity(let id): selectActivity(id: id)
      }
    }
  }

  private func changeFavorite(id: UUID) {
    if let idx = activities.firstIndex(where: { $0.id == id }) {
      activities[idx].isFavorite.toggle()
      selectedActivity = activities[idx]
    } else {
      assertionFailure() // TODO: handle this
    }
  }

  private func initialize() {
    activities = []
    errorDescription = ""
    errorRecoverySuggestion = ""
    haveError = false
    inputError = false
    loading = false
    location = CLLocation()
    mapItem = nil
    mapPosition = .automatic
    processing = false
    searchedCityState = ""
    selectedActivity = nil
  }

  private func loadMapItems() async {
    for activity in activities {
      guard !activity.address.isEmpty else { continue }
      guard activity.mapItem == nil else { continue }
      if let mapItem = await source.mapItemFrom(address: activity.address) {
        mapItem.name = activity.name
        if let idx = activities.firstIndex(where: { $0.id == activity.id }) {
          activities[idx].mapItem = mapItem
        }
      }
    }
  }

  private func processeMapItem(_ mapItem: MKMapItem) {
    let latitude = mapItem.location.coordinate.latitude
    let longitude = mapItem.location.coordinate.longitude
    let newCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let zoomOutDistance: CLLocationDistance = 10000 // meters
    mapPosition = MapCameraPosition.camera(
      MapCamera(centerCoordinate: newCoordinate, distance: zoomOutDistance)
    )
    if let cityState = mapItem.addressRepresentations?.cityWithContext {
      searchedCityState = cityState
    }
    withAnimation {
      self.mapItem = mapItem
    }
  }

  private func selectActivity(id: UUID) {
    if let idx = activities.firstIndex(where: { $0.id == id }) {
      selectedActivity = activities[idx]
    } else {
      print("activity.id=\(id) not found \(Date()) \(#file):\(#function):\(#line)")
      assertionFailure() // TODO: handle this
    }
  }
}
