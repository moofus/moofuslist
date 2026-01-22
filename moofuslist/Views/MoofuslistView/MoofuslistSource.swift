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
  enum SourceError: Error {
    case location(description: String?, recoverySuggestion: String?)
    case unknown(String)
  }

  enum Message {
    case error(SourceError)
    case badInput
    case initial
    case loaded
    case loading([AIManager.Activity])
    case mapItem(MKMapItem)
    case processing
    case select(Int) // the index of the selected activity
  }

  @Injected(\.aiManager) var aiManager: AIManager
  @Injected(\.locationManager) var locationManager: LocationManager

  private let continuation: AsyncStream<Message>.Continuation
  private(set) var locationToSearch = CLLocation()
  private let logger = Logger(subsystem: "com.moofus.Moofuslist", category: "MoofuslistSorce")
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Message.self)
    Task.detached { [weak self] in
      guard let self else { return }
      async let aiWait: Void = handleAIManager()
      async let locationWait: () = handleLocationManager()
      _ = await(aiWait, locationWait)
    }
  }
}


// MARK: - Private Location Methods
extension MoofuslistSource {
  private func handle(error: LocalizedError) async {
    let error = SourceError.location(
      description: error.errorDescription,
      recoverySuggestion: error.recoverySuggestion
    )
    continuation.yield(.error(error))
  }

  /// Given the CLLocation get the city and state
  /// - Parameter location: the location used to get the city and state
  /// - Returns: the "city, state"
  private func handle(location: CLLocation) async {
    if let request = MKReverseGeocodingRequest(location: location) { // ljw use cache
      do {
        let mapItems = try await request.mapItems
        if mapItems.count > 1 {
          print("mapItems.count=\(mapItems.count)")
          print(mapItems)
          assertionFailure()
        }
        if let mapItem = mapItems.first {
          await handle(mapItem: mapItem)
          return
        } else {
          assertionFailure()
          // ljw handle
        }
      } catch {
        logger.error("Error MKReverseGeocodingRequest: \(error)")
        assertionFailure("unknown error=\(error)")
        continuation.yield(.error(.unknown(error.localizedDescription)))
      }
    }
    let error = SourceError.location(description: "Can't get location", recoverySuggestion: nil)
    continuation.yield(.error(error))
  }

  private func handle(mapItem: MKMapItem) async {
    self.locationToSearch = mapItem.location
    if let cityState = mapItem.addressRepresentations?.cityWithContext {
     do {
       continuation.yield(.mapItem(mapItem))
       try await aiManager.findActivities(cityState: cityState)
     } catch {
       print("ljw \(Date()) \(#file):\(#function):\(#line)")
       print(error)
       if let error = error as? AIManager.Error {
         let error = SourceError.location(
           description: error.errorDescription,
           recoverySuggestion: error.recoverySuggestion
         )
         continuation.yield(.error(error))
       } else {
         assertionFailure("unknown error=\(error)")
         continuation.yield(.error(.unknown(error.localizedDescription)))
       }
     }
     return
    } else {
      // ljw handle
    }
  }

  @MainActor
  private func navigate(to route: AppCoordinator.Route) {
    @Injected(\.appCoordinator) var appCoordinator: AppCoordinator
    appCoordinator.navigate(to: route)
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
        continuation.yield(.loaded) // ljw handle activities.isEmpty
      case .error(_):
        assertionFailure() // ljw
      case .loading(let activities):
        continuation.yield(.loading(activities)) // ljw handle activities.isEmpty
      }
    }
  }

  private func handleLocationManager() async {
    for await message in locationManager.stream {
      print(message) // ljw add warnings for print statements

      switch message {
      case .error(let error):
        await handle(error: error)
      case .location(let location):
        await handle(location: location)
      }
    }
  }
}

// MARK: - Public Methods
extension MoofuslistSource {
  nonisolated
  func select(idx: Int) {
    Task { [weak self] in
      guard let self else { return }
      continuation.yield(.select(idx))
      await navigate(to: .detail)
    }
  }

  nonisolated
  func searchCityState(_ cityState: String) {
    Task {
      guard await cityState.validateTwoStringsSeparatedByComma() else {
        continuation.yield(.badInput)
        return
      }
      continuation.yield(.processing)
      let request = MKGeocodingRequest(addressString: cityState) // TODO: use cache
      do {
        let mapItem = (try await request?.mapItems.first)!
        await handle(mapItem: mapItem)
      } catch {
        logger.error("ljw cityState=\(cityState) \(Date()) \(#file):\(#function):\(#line)")
        print(error.localizedDescription)
        continuation.yield(.badInput)
      }
    }
  }

  nonisolated
  func searchCurrentLocation() {
    continuation.yield(.processing)
    Task {
      await locationManager.start(maxCount: 1)
    }
  }
}
