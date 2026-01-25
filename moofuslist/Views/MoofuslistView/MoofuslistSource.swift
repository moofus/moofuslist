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
    case loaded([Activity], Bool, Bool)
    case loading([Activity], Bool, Bool)
    case processing(MoofuslistUIData)
    case selectedActivity(Activity)
  }

  final class MoofuslistUIData {
    // keep the following properties insync with MoofuslistViewModel
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
  }

  @Injected(\.aiManager) var aiManager: AIManager
  @Injected(\.locationManager) var locationManager: LocationManager

  private var addressToLocationCache = [String: CLLocation]()
  private let continuation: AsyncStream<Message>.Continuation
  private var imageNames = ImageNames()
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  let stream: AsyncStream<Message>
  private var uiData = MoofuslistUIData()

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
  private func convert(activities: [AIManager.Activity], location: CLLocation) async -> [Activity] {
    var result = [Activity]()
    for activity in activities {
      let distance: Double
      do {
        distance = try await getDistance(from: activity, location: location)
      } catch {
        print("ljw \(Date()) \(#file):\(#function):\(#line)")
        logger.error("\(error.localizedDescription)")
        distance = activity.distance
      }

      result.append(
        Activity(
          address: activity.address,
          category: activity.category,
          city: activity.city,
          description: activity.description,
          distance: distance,
          imageNames: await imageNames(for: activity),
          name: activity.name,
          rating: activity.rating, // TODO: rating
          reviews: activity.reviews, // TODO: reviews
          somethingInteresting: activity.somethingInteresting,
          state: activity.state
        )
      )
    }
    return result
  }

  private func getDistance(from activity: AIManager.Activity, location: CLLocation) async throws -> Double {
    let activityLocation: CLLocation
    if let location = addressToLocationCache[activity.address] {
      activityLocation = location
      print("used cached")
    } else {
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = activity.address
      request.resultTypes = .address
      print("before search")
      let search = MKLocalSearch(request: request)
      print("after search")
      let response = try await search.start()
     print("after start")
      guard let activityMapItem = response.mapItems.first  else {
        return activity.distance
      }
      activityLocation = activityMapItem.location
      addressToLocationCache[activity.address] = activityLocation
    }
    let meters = activityLocation.distance(from: location)
    let distanceInMeters = Measurement(value: meters, unit: UnitLength.meters)
    let distanceInMiles = distanceInMeters.converted(to: UnitLength.miles)
    return distanceInMiles.value
  }

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

  private func imageNames(for activity: AIManager.Activity) async -> [String] {
    print("------------------------------")
    let activity = activity.lowercased()
    print(activity)

    var result = [String]()
    result = await imageNames.process(input: activity.name, result: &result)
    result = await imageNames.process(input: activity.category, result: &result)
    result = await imageNames.process(input: activity.description, result: &result)
    result = removeSimilarImages(result: &result)

    if result.count < 1 {
      print(activity)
      assertionFailure()
      return ["mappin.circle.fill"]
    }
    return result
  }

  private func initializeUIData() {
    uiData.activities = []
    uiData.errorDescription = ""
    uiData.errorRecoverySuggestion = ""
    uiData.haveError = false
    uiData.inputError = false
    uiData.loading = false
    uiData.location = CLLocation()
    uiData.mapItem = nil
    uiData.mapPosition = .automatic
    uiData.processing = false
    uiData.searchedCityState = ""
    uiData.selectedActivity = nil
  }

  @MainActor
  private func navigate(to route: AppCoordinator.Route) {
    @Injected(\.appCoordinator) var appCoordinator: AppCoordinator
    appCoordinator.navigate(to: route)
  }

  private func removeSimilarImages(result: inout [String]) -> [String] {
    if result.contains("building.columns.fill") {
      if let idx = result.firstIndex(of: "building.fill") {
        result.remove(at: idx)
      }
    }
    if result.contains("books.vertical.fill") {
      if let idx = result.firstIndex(of: "text.book.closed.fill") {
        result.remove(at: idx)
      }
    }
    if result.contains("building.2.fill") {
      if let idx = result.firstIndex(of: "building.fill") {
        result.remove(at: idx)
      }
    }
    return result
  }
}

// MARK: - Methods to send messages to MoofuslistViewModel
extension MoofuslistSource {
  private func sendError(
    description: String = "Error",
    recoverySuggestion: String = "Try again later."
  ) {
    initializeUIData()
    uiData.errorDescription = description
    uiData.errorRecoverySuggestion = recoverySuggestion
    send(message: .error(uiData))
  }

  private func sendInputError(inputError: Bool) {
    initializeUIData()
    uiData.inputError = inputError
    send(message: .error(uiData))
  }

  private func sendActivity(activity: Activity) {
    uiData.selectedActivity = activity
    send(message: .selectedActivity(activity))
  }

  private func sendLoaded(activities: [Activity], loading: Bool, processing: Bool) {
    uiData.activities = activities
    uiData.loading = loading
    uiData.processing = processing
    send(message: .loaded(activities, loading, processing))
  }

  private func sendLoading(activities: [AIManager.Activity], loading: Bool, processing: Bool) async {
    uiData.activities = await convert(activities: activities, location: uiData.location)
    uiData.loading = loading
    uiData.processing = processing
    send(message: .loading(uiData.activities, loading, processing))
  }

  private func sendProcessing(mapItem: MKMapItem) {
    uiData.mapItem = mapItem
    uiData.location = mapItem.location
    send(message: .processing(uiData))
  }

  private func sendProcessing(processing: Bool) {
    initializeUIData()
    uiData.processing = processing
    send(message: .processing(uiData))
  }

  private func send(message: Message) {
    Task { @MainActor in
      continuation.yield(message)
    }
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
        sendLoaded(activities: uiData.activities, loading: false, processing: false)
      case .error(_):
        assertionFailure() // TODO: handle
      case .loading(let activities):
        await sendLoading(activities: activities, loading: true, processing: false)
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
      await sendActivity(activity: activity)
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
