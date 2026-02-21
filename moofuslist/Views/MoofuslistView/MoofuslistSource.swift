//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit
@preconcurrency import MapKit
import os
import SwiftData
import SwiftUI


final actor MoofuslistSource {
  enum Message {
    case error(String, String) // description, recoverySuggestion
    case haveFavorites(Bool)
    case initialize
    case inputError
    case loaded(loading: Bool)
    case loading(activities: [MoofuslistActivity], favorites: Bool, processing: Bool)
    case mapInfo(MapInfo)
    case processing
    case selectActivity(UUID)
    case setIsFavorite(Bool, UUID)
    case storageError(String, String)
  }

 private struct LocationKey: Hashable {
    let latitude: Double
    let longitude: Double
  }

  @Injected(\.aiManager) private var aiManager: AIManager
  @Injected(\.locationManager) private var locationManager: LocationManager

  private var activities = [MoofuslistActivity]()
  private var addressToMapItemCache = [String: MKMapItem]()
  private let continuation: AsyncStream<Message>.Continuation
  private var imageNames = ImageNames()
  private var location = CLLocation()
  private var locationToMapItemCache = [LocationKey: MKMapItem]()
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  private var storageManager: StorageManager!

  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream<Message>.makeStream()

    Task.detached { [weak self] in
      guard let self else { return }
      await self.initializeStorageManager()
      async let aiWait: Void = handleAIManager()
      async let locationWait: Void = handleLocationManager()
      _ = await(aiWait, locationWait)
    }

    Task { @MainActor in
      @Injected(\.moofuslistCoordinator) var moofuslistCoordinator: MoofuslistCoordinator

      for await message in moofuslistCoordinator.stream {
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
  
  private func initializeStorageManager() async {
    do {
      let schema = Schema([MoofuslistActivityModel.self])
      let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
      let container = try ModelContainer(for: schema, configurations: [configuration])
      storageManager = Container.shared.storageManager(container)
      let count = try await storageManager.countAllActivities()
      send(messages: [.haveFavorites(count > 0)])
    } catch {
      logger.error("\(error)")
      send(messages: [.storageError("Storage initialization failed", error.localizedDescription)])
      return
    }
  }
}

// MARK: - Methods to send messages to MoofuslistViewModel
extension MoofuslistSource {
  private func sendError(description: String = "Error", recoverySuggestion: String = "Try again later.") {
    send(messages: [.error(description, recoverySuggestion)])
  }

  private func sendLoaded(loading: Bool) {
    send(messages: [.loaded(loading: loading)])
  }

  private func sendLoading(activities: [AIManager.Activity], processing: Bool) async {
    self.activities = await convert(activities: activities, location: location)
    send(messages: [.loading(activities: self.activities, favorites: false, processing: processing)])
  }

  private func send(messages: [Message]) {
    Task { @MainActor in
      for message in messages {
        continuation.yield(message)
      }
    }
  }
}

// MARK: - Private Handle Managers
extension MoofuslistSource {
  private func handleAIManager() async {
    for await message in aiManager.stream {
      switch message {
      case .begin:
        await navigate(to: .content)
      case .end:
        send(messages: [.loaded(loading: false)])
      case .error(let error):
        send(messages: [.initialize])
        if let description = error.errorDescription, let recoverySuggestion = error.recoverySuggestion {
          sendError(description: description, recoverySuggestion: recoverySuggestion)
        } else {
          assertionFailure()
          sendError()
        }
      case .loading(let activities):
        await sendLoading(activities: activities, processing: false)
      }
    }
  }

  private func handleLocationManager() async {
    for await message in locationManager.stream {
      print(message) // TODO: install swiftlint add warnings for print statements

      switch message {
      case .error(let error):
        send(messages: [.initialize])
        if let description = error.errorDescription, let recoverySuggestion = error.recoverySuggestion {
          sendError(description: description, recoverySuggestion: recoverySuggestion)
        } else if let description = error.errorDescription {
          sendError(description: description)
        } else {
          assertionFailure()
          sendError()
        }
      case .info(let info):
        logger.info("From LocationManager: \(info.rawValue)")
      case .location(let location):
        await handle(location: location)
      }
    }
  }
}

// MARK: - Private Location Methods
extension MoofuslistSource {
  /// Given the CLLocation get the city and state
  /// - Parameter location: the location used to get the mapItem
  private func handle(location: CLLocation) async {
    let mapItem: MKMapItem
    let locationKey = LocationKey(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    if let item = locationToMapItemCache[locationKey] {
      mapItem = item
    } else {
      if let request = MKReverseGeocodingRequest(location: location) {
        do {
          let mapItems = try await request.mapItems
          guard let item = mapItems.first else {
            logger.error("MapItem not found \(#file):\(#line)")
            send(messages: [.initialize])
            sendError(description: "MapItem not found")
            assertionFailure()
            return
          }
          mapItem = item
          locationToMapItemCache[locationKey] = mapItem
        } catch {
          logger.error("MKReverseGeocodingRequest: \(error)")
          send(messages: [.initialize])
          sendError(description: error.localizedDescription)
          assertionFailure("unknown error=\(error)")
          return
        }
      } else {
        send(messages: [.initialize])
        sendError(description: "Can't get location")
        assertionFailure()
        return
      }
    }
    await handle(mapItem: mapItem)
  }
}

// MARK: - Private Methods
extension MoofuslistSource {
  private func convert(activities: [AIManager.Activity], location: CLLocation) async -> [MoofuslistActivity] {
    var result = [MoofuslistActivity]()
    for activity in activities {
      let distance: Double
      do {
        distance = try await getDistance(from: activity, location: location)
      } catch {
        logger.error("\(error.localizedDescription)")
        distance = activity.distance
      }
      var mapItem: MKMapItem?
      if let item = await mapItemFrom(address: activity.address) {
        mapItem = item
      }

      let newActivity = MoofuslistActivity(
        address: activity.address,
        category: activity.category,
        city: activity.city,
        desc: activity.description,
        distance: distance,
        imageNames: await imageNames.imageNames(for: activity),
        isFavorite: false,
        latitude: mapItem?.location.coordinate.latitude,
        longitude: mapItem?.location.coordinate.longitude,
        name: activity.name,
        phoneNumber: activity.phoneNumber,
        rating: activity.rating, // TODO: rating
        reviews: activity.reviews, // TODO: reviews
        somethingInteresting: activity.somethingInteresting,
        state: activity.state
      )
      result.append(newActivity)
    }
    return result
  }

//  private func convert(activities: [MoofuslistActivityModel]) async -> [MoofuslistActivity] {
//    var result = [MoofuslistActivity]()
//    for activity in activities {
//      let newActivity = MoofuslistActivity(
//        id: activity.id,
//        address: activity.address,
//        category: activity.category,
//        city: activity.city,
//        desc: activity.desc,
//        distance: activity.distance,
//        imageNames: activity.imageNames,
//        isFavorite: activity.isFavorite,
//        latitude: activity.latitude,
//        longitude: activity.longitude,
//        name: activity.name,
//        phoneNumber: activity.phoneNumber,
//        rating: activity.rating,
//        reviews: activity.reviews,
//        somethingInteresting: activity.somethingInteresting,
//        state: activity.state
//      )
//      result.append(newActivity)
//    }
//    return result
//  }

  private func getDistance(from activity: AIManager.Activity, location: CLLocation) async throws -> Double {
    guard let mapItem = await mapItemFrom(address: activity.address) else {
      return activity.distance
    }
    let meters = mapItem.location.distance(from: location)
    let distanceInMeters = Measurement(value: meters, unit: UnitLength.meters)
    let distanceInMiles = distanceInMeters.converted(to: UnitLength.miles)
    return distanceInMiles.value
  }

  private func handle(mapItem: MKMapItem) async {
    guard let cityState = mapItem.addressRepresentations?.cityWithContext else {
      logger.error("mapItem.addressRepresentations is nil")
      assertionFailure()
      send(messages: [.initialize])
      sendError()
      return
    }

    do {
      let mapInfo = MapInfo(
        latitude: mapItem.location.coordinate.latitude,
        longitude: mapItem.location.coordinate.longitude,
        cityState: cityState
      )
      send(messages: [.mapInfo(mapInfo)])
      try await aiManager.findActivities(cityState: cityState)
    } catch {
      print(error)
      send(messages: [.initialize])
      if let error = error as? AIManager.Error {
        sendError(description: error.errorDescription ?? "", recoverySuggestion: error.recoverySuggestion ?? "")
      } else {
        logger.error("unknown error=\(error)")
        assertionFailure()
        sendError(description: "Failed to handle map item", recoverySuggestion: "Restart App")
      }
      return
    }
  }

  private func mapItemFrom(address: String) async -> MKMapItem? {
    if let mapItem = addressToMapItemCache[address] {
      return mapItem
    }

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = address
    request.resultTypes = .address
    //    print("before search")
    let search = MKLocalSearch(request: request)
    print("after search")
    do {
      let response = try await search.start()
      print("after start")
      if let mapItem = response.mapItems.first {
        //        print("ljw address=\(String(describing: address)) \(Date()) \(#file):\(#function):\(#line)")
        //        print("ljw mapItem=\(String(describing: mapItem.address?.fullAddress)) \(Date()) \(#file):\(#function):\(#line)")
        addressToMapItemCache[address] = mapItem
        return mapItem
      }
    } catch {
      logger.error("address=\(address) \(Date()) \(#file):\(#function):\(#line)")
      print(error)
      return nil
    }

    /*
     let request = MKGeocodingRequest(addressString: address)
     do {
     if let mapItem = try await request?.mapItems.first {
     print("ljw address=\(String(describing: address)) \(Date()) \(#file):\(#function):\(#line)")
     print("ljw mapItem=\(String(describing: mapItem.address?.fullAddress)) \(Date()) \(#file):\(#function):\(#line)")
     addressToMapItemCache[address] = mapItem
     return mapItem
     }
     } catch {
     logger.error("ljw address=\(address) \(Date()) \(#file):\(#function):\(#line)")
     print(error.localizedDescription)
     }
     */

    return nil
  }

  @MainActor
  private func navigate(to route: MoofuslistCoordinator.Route) {
    @Injected(\.moofuslistCoordinator) var moofuslistCoordinator: MoofuslistCoordinator
    moofuslistCoordinator.navigate(to: route)
  }
}

// MARK: - Private Methods for the Public methods
extension MoofuslistSource {
  private func displayFavorites(_ arg: Int?) async {
    do {
      await navigate(to: .content)
      self.activities = try await storageManager.fetchAllActivities()
      send(messages: [.loading(activities: self.activities, favorites: true, processing: false)])
      send(messages: [.loaded(loading: false)])
    } catch {
      // TODO: handle
      assertionFailure()
    }
  }

  private func searchCityState(cityState: String) async {
    if let mapItem = await mapItemFrom(address: cityState) {
      send(messages: [.initialize, .processing])
      await handle(mapItem: mapItem)
    } else {
      logger.error("cityState=\(cityState) \(Date()) \(#file):\(#function):\(#line)")
      send(messages: [.initialize, .inputError])
    }
  }

  private func searchCurrentLocation(_ arg: Int?) async {
    send(messages: [.initialize, .processing])
    await locationManager.start(maxCount: 1)
  }

  private func selectActivity(id: UUID) async {
    send(messages: [.selectActivity(id)])
    await navigate(to: .detail)
  }

  private func setIsFavorite(isFavorite: Bool, for id: UUID) async {
    guard let idx = activities.firstIndex(where: { $0.id == id }) else {
      logger.error("id=\(id)")
      logger.error("activities=\(self.activities)")
      send(messages: [.error("Activity not found", "Exit and restart application")])
      assertionFailure()
      return
    }
    activities[idx].isFavorite = isFavorite

    if isFavorite {
      do {
        try await storageManager.insert(activity: activities[idx])
        let count = try await storageManager.countAllActivities()
        await send(messages: [.setIsFavorite(isFavorite, id), .haveFavorites(count > 0)])
      } catch {
        logger.error("\(error)")
        send(messages: [.error("Failed to create favorite", error.localizedDescription)]) // TODO: fix data error.lo...
        assertionFailure()
        return
      }
    } else {
      do {
        try await storageManager.delete(with: id)
        let count = try await storageManager.countAllActivities()
        await send(messages: [.setIsFavorite(isFavorite, id), .haveFavorites(count > 0)])
      } catch {
        logger.error("\(error)")
        send(messages: [.error("Failed to delete favorite", error.localizedDescription)]) // TODO: fix data error.lo...
        assertionFailure()
        return
      }
      return
    }
  }
}

// MARK: - Public Methods
extension MoofuslistSource {
  nonisolated func displayFavorites() {
    Task.detached { [weak self] in
      await self?.displayFavorites(nil)
    }
  }

  nonisolated func searchCityState(_ cityState: String) {
    Task.detached { [weak self] in
      await self?.searchCityState(cityState: cityState)
    }
  }

  nonisolated func searchCurrentLocation() {
    Task.detached { [weak self] in
      await self?.searchCurrentLocation(nil)
    }
  }

  nonisolated func selectActivity(for id: UUID) {
    Task.detached { [weak self] in
      await self?.selectActivity(id: id)
    }
  }

  nonisolated func setIsFavorite(_ isFavorite: Bool, for id: UUID) {
    Task.detached { [weak self] in
      await self?.setIsFavorite(isFavorite: isFavorite, for: id)
    }
  }
}

