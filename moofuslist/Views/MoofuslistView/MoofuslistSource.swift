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

    init() { }

    init(activities: [Activity], uiData: MoofuslistUIData) {
      self.activities = activities
      self.errorDescription = uiData.errorDescription
      self.errorRecoverySuggestion = uiData.errorRecoverySuggestion
      self.haveError = uiData.haveError
      self.inputError = uiData.inputError
      self.loading = uiData.loading
      self.location = uiData.location
      self.mapItem = uiData.mapItem
      self.mapPosition = uiData.mapPosition
      self.processing = uiData.processing
      self.searchedCityState = uiData.searchedCityState
      self.selectedActivity = uiData.selectedActivity
    }
  }

  @Injected(\.aiManager) var aiManager: AIManager
  @Injected(\.locationManager) var locationManager: LocationManager

  private let continuation: AsyncStream<Message>.Continuation
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  private var uiData = MoofuslistUIData() // Note: activities is always 0 in source, but not in viewModel
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

  private func sendInputError(inputError: Bool) {
    initializeUIData()
    uiData.inputError = inputError
    continuation.yield(.error(uiData))
  }

  private func sendLoaded(activity: Activity) {
    uiData.selectedActivity = activity
    continuation.yield(.loaded(uiData))
  }

  private func sendLoaded(loading: Bool, processing: Bool) {
    uiData.loading = loading
    uiData.processing = processing
    continuation.yield(.loaded(uiData))
  }

  private func sendLoading(activities: [AIManager.Activity], loading: Bool, processing: Bool) {
    uiData.loading = loading
    uiData.processing = processing
    continuation.yield(.loading(activities, uiData)) // TODO: convert here?
  }

  private func sendProcessing(mapItem: MKMapItem) {
    uiData.mapItem = mapItem
    uiData.location = mapItem.location
    continuation.yield(.processing(uiData))
  }

  private func sendProcessing(processing: Bool) {
    initializeUIData()
    uiData.processing = processing
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
        sendLoaded(loading: false, processing: false)
      case .error(_):
        assertionFailure() // TODO: handle
      case .loading(let activities):
        if !activities.isEmpty {
          sendLoading(activities: activities, loading: true, processing: false)
        } else {
          print("activities form aimanager is zero")
        }
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
      await sendLoaded(activity: activity)
      await navigate(to: .detail)
    }
  }

  nonisolated
  func searchCityState(_ cityState: String) {
    Task {
      await sendProcessing(processing: true)
      let request = MKGeocodingRequest(addressString: cityState) // TODO: use cache
      do {
        if let mapItem = (try await request?.mapItems.first) {
          await handle(mapItem: mapItem)
        } else {
          assertionFailure()
          await sendError(description: "MKGeocodingRequest")
        }
      } catch {
        logger.error("ljw cityState=\(cityState) \(Date()) \(#file):\(#function):\(#line)")
        print(error.localizedDescription)
        await sendInputError(inputError: true)
      }
    }
  }

  nonisolated
  func searchCurrentLocation() {
    Task {
      await sendProcessing(processing: true)
      await locationManager.start(maxCount: 1)
    }
  }
}
