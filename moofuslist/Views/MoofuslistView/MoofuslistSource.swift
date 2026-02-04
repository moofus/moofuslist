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
import SwiftData
import SwiftUI


final actor MoofuslistSource {
  typealias Activity = MoofuslistViewModel.Activity

  enum Message {
    case changeFavorite(UUID)
    case error(String, String)
    case initialize
    case inputError(Bool)
    case loaded(Bool)
    case loading([Activity], Bool, Bool)
    case loadMapItems
    case mapItem(MKMapItem)
    case processing
    case selectActivity(UUID)
  }

 private struct LocationKey: Hashable {
    let latitude: Double
    let longitude: Double
  }

  @Injected(\.aiManager) private var aiManager: AIManager
  @Injected(\.locationManager) private var locationManager: LocationManager
  private var storageManager: StorageManager

  private var addressToMapItemCache = [String: MKMapItem]()
  private let continuation: AsyncStream<Message>.Continuation
  private var imageNames = ImageNames()
  private var location = CLLocation()
  private var locationToMapItemCache = [LocationKey: MKMapItem]()
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream<Message>.makeStream()

    do {
      let schema = Schema([MoofuslistActivity.self])
      let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
      let container = try ModelContainer(for: schema, configurations: [configuration])
      storageManager = Container.shared.storageManager(container)
    } catch {
      logger.error("\(error)")
      fatalError()
    }

    Task.detached { [weak self] in
      guard let self else { return }
      await storageManager.initialize()
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
}

// MARK: - Methods to send messages to MoofuslistViewModel
extension MoofuslistSource {
  private func sendError(description: String = "Error", recoverySuggestion: String = "Try again later.") {
    send(message: .initialize)
    send(message: .error(description, recoverySuggestion))
  }

  private func sendInputError(inputError: Bool) {
    send(message: .initialize)
    send(message: .inputError(true))
  }

  private func sendLoaded(loading: Bool) {
    send(message: .loaded(loading))
  }

  private func sendLoading(activities: [AIManager.Activity], loading: Bool, processing: Bool) async {
    let activities = await convert(activities: activities, location: location)
    send(message: .loading(activities, loading, processing))
  }

  private func sendProcessing(processing: Bool) {
    send(message: .initialize)
    send(message: .processing)
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
        await navigate(to: .content)
      case .end:
        send(message: .loaded(false))
      case .error(let error):
        if let description = error.errorDescription, let recoverySuggestion = error.recoverySuggestion {
          sendError(description: description, recoverySuggestion: recoverySuggestion)
        } else {
          assertionFailure()
          sendError()
        }
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
  /// - Parameter location: the location used to get the city and state
  /// - Returns: the "city, state"
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
            sendError(description: "MapItem not found")
            assertionFailure()
            return
          }
          mapItem = item
          locationToMapItemCache[locationKey] = mapItem
        } catch {
          logger.error("Error MKReverseGeocodingRequest: \(error)")
          sendError(description: error.localizedDescription)
          assertionFailure("unknown error=\(error)")
          return
        }
      } else {
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
  private func convert(activities: [AIManager.Activity], location: CLLocation) async -> [Activity] {
    var result = [Activity]()
    for activity in activities {
      let distance: Double
      do {
        distance = try await getDistance(from: activity, location: location)
      } catch {
        logger.error("\(error.localizedDescription)")
        distance = activity.distance
      }

      result.append(
        Activity(
          address: activity.address,
          category: activity.category,
          city: activity.city,
          desc: activity.description,
          distance: distance,
          imageNames: await imageNames.imageNames(for: activity),
          name: activity.name,
          rating: activity.rating, // TODO: rating
          reviews: activity.reviews, // TODO: reviews
          phoneNumber: activity.phoneNumber,
          somethingInteresting: activity.somethingInteresting,
          state: activity.state
        )
      )
    }
    return result
  }

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
    if let cityState = mapItem.addressRepresentations?.cityWithContext {
      do {
        send(message: .mapItem(mapItem))
        try await aiManager.findActivities(cityState: cityState)
      } catch {
        print(error)
        if let error = error as? AIManager.Error {
          sendError(description: error.errorDescription ?? "", recoverySuggestion: error.recoverySuggestion ?? "")
        } else {
          assertionFailure("unknown error=\(error)")
          sendError(description: error.localizedDescription)
        }
      }
    } else {
      assertionFailure()
      sendError()
    }
  }

  @MainActor
  private func navigate(to route: MoofuslistCoordinator.Route) {
    @Injected(\.moofuslistCoordinator) var moofuslistCoordinator: MoofuslistCoordinator
    moofuslistCoordinator.navigate(to: route)
  }
}

// MARK: - Public Methods
extension MoofuslistSource {
  nonisolated func changeFavorite(id: UUID) {
    Task.detached { [weak self] in
      await self?.send(message: .changeFavorite(id))
    }
  }

  nonisolated func loadMapItems() async {
    await send(message: .loadMapItems)
  }

  func mapItemFrom(address: String) async -> MKMapItem? {
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

  nonisolated func searchCityState(_ cityState: String) {
    Task.detached { [weak self] in
      guard let self else { return }
      await sendProcessing(processing: true)
      if let mapItem = await mapItemFrom(address: cityState) {
        await handle(mapItem: mapItem)
      } else {
        logger.error("cityState=\(cityState) \(Date()) \(#file):\(#function):\(#line)")
        await sendInputError(inputError: true)
      }
    }
  }

  nonisolated func searchCurrentLocation() {
    Task.detached { [weak self] in
      guard let self else { return }
      await sendProcessing(processing: true)
      await locationManager.start(maxCount: 1)
    }
  }

  nonisolated func selectActivity(id: UUID) {
    Task.detached { [weak self] in
      guard let self else { return }
      await send(message: .selectActivity(id))
      await navigate(to: .detail)
    }
  }
}
