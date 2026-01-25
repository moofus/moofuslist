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
final
class MoofuslistViewModel {
  struct Activity: Hashable, Identifiable {
    let id = UUID()
    let address: String
    let category: String
    let city: String
    let description: String
    let distance: Double
    let imageNames: [String]
    var isFavorite = false
    let name: String
    let rating: Double
    let reviews: Int
    let somethingInteresting: String
    let state: String
  }

  @ObservationIgnored @Injected(\.moofuslistSource) private var source: MoofuslistSource

  // keep the following properties insync with MoofuslistUIData
  var activities: [Activity] = []
  var errorDescription: String = ""
  var errorRecoverySuggestion: String = ""
  var haveError: Bool = false
  var inputError: Bool = false
  var loading: Bool = false
  var location = CLLocation()
  var mapItem: MKMapItem? = nil
  var mapPosition: MapCameraPosition = .automatic
  var processing: Bool = false
  var searchedCityState: String = ""
  var selectedActivity: Activity? = nil

  init() {
    handleSource()
  }
}

// MARK: - Private Methods
extension MoofuslistViewModel {
  private func handleSource() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      for await message in await source.stream {
        print("ljw handleSource message \(Date()) \(#file):\(#function):\(#line)")
        print(message)
        switch message {
        case let .error(uiData):
          setAll(uiData: uiData)
        case let .loaded(activities, loading, processing):
          print("ljw loaded setting activities.count=\(activities.count) \(Date()) \(#file):\(#function):\(#line)")
          self.activities = activities
          self.loading = loading
          self.processing = processing
        case let .loading(activities, loading, processing):
          self.activities = activities
          self.loading = loading
          self.processing = processing
        case let .processing(uiData):
          print("ljw processing setting activities.count=\(uiData.activities.count) \(Date()) \(#file):\(#function):\(#line)")
          setAll(uiData: uiData)
          processeMapItem(uiData: uiData)
        case let .selectedActivity(activity):
          selectedActivity = activity
        }
      }
    }
  }

  private func processeMapItem(uiData: MoofuslistSource.MoofuslistUIData) {
    guard let mapItem = uiData.mapItem else {
      return
    }

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
      self.mapItem = mapItem // TODO: test visually
    }
  }

  private func setAll(uiData: MoofuslistSource.MoofuslistUIData) {
    activities = uiData.activities
    errorDescription = uiData.errorDescription
    errorRecoverySuggestion = uiData.errorRecoverySuggestion
    haveError = uiData.haveError
    inputError = uiData.inputError
    loading = uiData.loading
    location = uiData.location
    mapItem = uiData.mapItem
    mapPosition = uiData.mapPosition
    processing = uiData.processing
    searchedCityState = uiData.searchedCityState
    selectedActivity = uiData.selectedActivity
  }
}
