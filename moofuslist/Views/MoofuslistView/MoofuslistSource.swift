//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit
import MapKit
import os
import SwiftUI

final actor MoofuslistSource {
  typealias Activity = MoofuslistViewModel.Activity

  enum Message {
    case error(MoofuslistUIData)
    case loaded(MoofuslistUIData)
    case loading([AIManager.Activity], MoofuslistUIData)
    case processing(MoofuslistUIData)
  }

  @Observable
  final class MoofuslistUIData {
    var activities: [Activity]
    var errorDescription: String
    var errorRecoverySuggestion: String
    var haveError: Bool
    var inputError: Bool
    var loading: Bool
    var mapItem: MKMapItem?
    var mapPosition: MapCameraPosition
    var processing: Bool
    var searchedCityState: String
    var selectedActivity: Activity?

    init(
      activities: [Activity] = [],
      errorDescription: String = "",
      errorRecoverySuggestion: String = "",
      haveError: Bool = false,
      inputError: Bool = false,
      loading: Bool = false,
      mapItem: MKMapItem? = nil,
      mapPosition: MapCameraPosition = .automatic,
      processing: Bool = false,
      searchedCityState: String = "",
      selectedActivity: Activity? = nil
    ) {
      self.activities = activities
      self.errorDescription = errorDescription
      self.errorRecoverySuggestion = errorRecoverySuggestion
      self.haveError = haveError
      self.inputError = inputError
      self.loading = loading
      self.mapItem = mapItem
      self.mapPosition = mapPosition
      self.processing = processing
      self.searchedCityState = searchedCityState
      self.selectedActivity = selectedActivity
    }
  }

  @Injected(\.aiManager) var aiManager: AIManager
  @Injected(\.locationManager) var locationManager: LocationManager

  private let continuation: AsyncStream<Message>.Continuation
  private(set) var locationToSearch = CLLocation()
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  private var uiData = MoofuslistUIData() // source of truth
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Message.self)
    Task.detached { [weak self] in
      guard let self else { return }
      async let aiWait: Void = handleAIManager()
      async let locationWait: () = handleLocationManager()
      _ = await(aiWait, locationWait)
    }

    Task { @MainActor in
      @Injected(\.appCoordinator) var appCoordinator: AppCoordinator

      for await message in appCoordinator.stream {
        switch message {
        case .content:
          print("source content")
        case .detail:
          print("source detail")
        case .sidebar:
          print("source sidebar")
        }
      }
    }
  }
}

// MARK: - Private Location Methods
extension MoofuslistSource {
  /// Given the CLLocation get the city and state
  /// - Parameter location: the location used to get the city and state
  /// - Returns: the "city, state"
  private func handle(location: CLLocation) async {
    if let request = MKReverseGeocodingRequest(location: location) { // TODO: use cache
      do {
        let mapItems = try await request.mapItems
        if mapItems.count > 1 { // TODO: remove
          print("mapItems.count=\(mapItems.count)")
          print(mapItems)
          assertionFailure()
        }
        if let mapItem = mapItems.first {
          await handle(mapItem: mapItem)
          return
        } else {
          assertionFailure()
          // TODO: handle
        }
      } catch {
        logger.error("Error MKReverseGeocodingRequest: \(error)")
        assertionFailure("unknown error=\(error)")
        sendError(description: error.localizedDescription)
        return
      }
    }
    sendError(description: "Can't get location")
  }
}

// MARK: - Private Methods
extension MoofuslistSource {
  private func handle(mapItem: MKMapItem) async {
    self.locationToSearch = mapItem.location
    if let cityState = mapItem.addressRepresentations?.cityWithContext {
      do {
        sendProcessing(mapItem: mapItem)
        try await aiManager.findActivities(cityState: cityState)
      } catch {
        print("ljw \(Date()) \(#file):\(#function):\(#line)")
        print(error)
        if let error = error as? AIManager.Error {
          sendError(description: error.errorDescription ?? "", recoverySuggestion: error.recoverySuggestion ?? "")
        } else {
          assertionFailure("unknown error=\(error)")
          sendError(description: error.localizedDescription)
        }
      }
      return
    } else {
      // TODO: handle
    }
  }

  private func initializeUIData() {
    uiData.activities = []
    uiData.inputError = false
    uiData.haveError = false
    uiData.loading = false
// TODO:     uiData.mapItem = nil
// TODO:     uiData.mapPosition = .automatic
    uiData.processing = false
  }

  @MainActor
  private func navigate(to route: AppCoordinator.Route) {
    @Injected(\.appCoordinator) var appCoordinator: AppCoordinator
    appCoordinator.navigate(to: route)
  }

  private func sendError(
    description: String = "Error",
    recoverySuggestion: String = "Try again later."
  ) {
    initializeUIData()
    uiData.errorDescription = description
    uiData.errorRecoverySuggestion = recoverySuggestion
    continuation.yield(.error(uiData))
  }

  private func sendInputError() {
    initializeUIData()
    uiData.inputError = true
    continuation.yield(.error(uiData))
  }

  private func sendLoaded(activity: Activity) {
    uiData.selectedActivity = activity
    continuation.yield(.loaded(uiData))
  }

  private func sendLoaded(loading: Bool) {
    uiData.loading = false
    uiData.processing = false
    continuation.yield(.loaded(uiData))
  }

  private func sendLoading(activities: [AIManager.Activity]) {
    uiData.processing = false
    continuation.yield(.loading(activities, uiData)) // TODO: convert here?
  }

  private func sendProcessing(mapItem: MKMapItem) {
    uiData.mapItem = mapItem
    continuation.yield(.processing(uiData))
  }

  private func sendProcessing() {
    initializeUIData()
    uiData.processing = true // TODO: investigate, may not need processing just use loading
    continuation.yield(.processing(uiData))
  }
}

// MARK: - Private Handle Managers
extension MoofuslistSource {
  private func handleAIManager() async {
    for await message in aiManager.stream {
      switch message {
      case .begin:
        print("ljw begin \(Date()) \(#file):\(#function):\(#line)")
        await navigate(to: .content)
      case .end:
        print("ljw end \(Date()) \(#file):\(#function):\(#line)")
        sendLoaded(loading: false)
      case .error(_):
        assertionFailure() // TODO: handle
      case .loading(let activities):
        sendLoading(activities: activities)
      }
    }
  }

  private func handleLocationManager() async {
    for await message in locationManager.stream {
      print(message) // ljw add warnings for print statements

      switch message {
      case .error(let error):
        sendError(
          description: error.errorDescription ?? "",
          recoverySuggestion: error.recoverySuggestion ?? ""
        )
      case .location(let location):
        await handle(location: location)
      }
    }
  }
}

// MARK: - Public Methods
extension MoofuslistSource {
  nonisolated
  func select(activity: MoofuslistViewModel.Activity) {
    Task { [weak self] in
      guard let self else { return }
      print("ljw \(Date()) \(#file):\(#function):\(#line)")
      await sendLoaded(activity: activity)
      await navigate(to: .detail)
    }
  }

  nonisolated
  func searchCityState(_ cityState: String) {
    Task {
      guard await cityState.validateTwoStringsSeparatedByComma() else {
        await sendInputError()
        return
      }
      await sendProcessing()
      let request = MKGeocodingRequest(addressString: cityState) // TODO: use cache
      do {
        let mapItem = (try await request?.mapItems.first)!
        await handle(mapItem: mapItem)
      } catch {
        logger.error("ljw cityState=\(cityState) \(Date()) \(#file):\(#function):\(#line)")
        print(error.localizedDescription)
        await sendInputError()
      }
    }
  }

  nonisolated
  func searchCurrentLocation() {
    Task {
      await sendProcessing()
      await locationManager.start(maxCount: 1)
    }
  }
}
