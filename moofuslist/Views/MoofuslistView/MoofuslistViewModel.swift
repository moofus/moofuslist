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
  @ObservationIgnored @Injected(\.moofuslistSource) private var source: MoofuslistSource

  private(set) var activities: [MoofuslistActivity] = []
  private(set) var contentTitle = ""
  private(set) var errorDescription = ""
  private(set) var errorRecoverySuggestion = ""
  var haveError = false
  private(set) var haveFavorites = false
  var inputError = false
  private(set) var loading = false
  private(set) var location = CLLocation()
  private(set) var mapItem: MKMapItem? = nil
  var mapPosition: MapCameraPosition = .automatic
  private(set) var processing = false
  private(set) var searchedCityState = ""
  private(set) var selectedActivity: MoofuslistActivity? = nil

  init() {
    Task {
      await handleSource()
    }
  }
}

// MARK: Methods
extension MoofuslistViewModel {
  private func handleSource() async {
    for await message in source.stream {
      print(message)
      switch message {
      case let .error(description, recoverySuggestion):
        errorDescription = description
        errorRecoverySuggestion = recoverySuggestion
      case .haveFavorites(let value): haveFavorites = value
      case .initialize: initialize()
      case .inputError: inputError = true
      case .loaded(let loading): self.loading = loading
      case let .loading(activities, favorites, processing):
        handleLoading(activities: activities, favorites: favorites, processing: processing)
      case .mapItem(let mapItem): processeMapItem(mapItem)
      case .processing: processing = true
      case .selectActivity(let id): selectActivity(id: id)
      case let .setIsFavorite(isFavorite, id): set(isFavorite: isFavorite, for: id)
      case let .storageError(str1, str2):
        print("str1=\(str1)") // TODO: handle this
        print("str2=\(str2)")
        assertionFailure()
      }
    }
  }

  private func handleLoading(activities: [MoofuslistActivity], favorites: Bool, processing: Bool) {
    if favorites {
      contentTitle = "Favorites"
    }
    self.activities = activities
    self.loading = true
    self.processing = processing
  }

  private func initialize() {
    activities = []
    contentTitle = ""
    errorDescription = ""
    errorRecoverySuggestion = ""
    haveError = false
    inputError = false
    loading = false
    location = CLLocation()
    mapItem = nil
    mapPosition = .automatic
    processing = false
    selectedActivity = nil
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
      contentTitle = "Activities near \(cityState)"
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
      assertionFailure()
    }
  }

  private func set(isFavorite: Bool, for id: UUID) {
    if let idx = activities.firstIndex(where: { $0.id == id }) {
      activities[idx].isFavorite = isFavorite
      selectedActivity = activities[idx] // to ensure MoofuslistDetailView is updated
    } else {
      assertionFailure()
    }
  }
}

#if DEBUG
// MARK: - TestHooks
extension MoofuslistViewModel {
  var testHooks: TestHooks {
    TestHooks(viewModel: self)
  }
  
  struct TestHooks {
    let viewModel: MoofuslistViewModel

    var activities: [MoofuslistActivity] {
      get { viewModel.activities }
      set { viewModel.activities = newValue }
    }

    var contentTitle: String {
      get { viewModel.contentTitle }
      set { viewModel.contentTitle = newValue }
    }

    var selectedActivity: MoofuslistActivity? {
      get { viewModel.selectedActivity }
      set { viewModel.selectedActivity = newValue }
    }
  }
}
#endif
