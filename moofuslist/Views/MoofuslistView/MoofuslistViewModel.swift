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

@Observable
final
class MoofuslistViewModel {
  typealias MoofuslistUIData = MoofuslistSource.MoofuslistUIData
  
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

  @ObservationIgnored private var addressToLocationCache = [String: CLLocation]()
  @ObservationIgnored private var imageNames = ImageNames()
  @ObservationIgnored private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "MoofuslistViewModel")
  @MainActor var uiData = MoofuslistSource.MoofuslistUIData()

  init() {
    handleSource()
  }
}

// MARK: - Private Methods
extension MoofuslistViewModel {
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
/*Throttled "PlaceRequest.REQUEST_TYPE_SEARCH" request: Tried to make more than 50 requests in 60 seconds, will reset in 46 seconds - Error Domain=GEOErrorDomain Code=-3 "(null)" UserInfo={details=(
 {
 intervalType = short;
 maxRequests = 50;
 "throttler.keyPath" = "app:moofus.com.moofuslist/0x20301/short(default/any)";
 timeUntilReset = 46;
 windowSize = 60;
}
), requestKindString=PlaceRequest.REQUEST_TYPE_SEARCH, timeUntilReset=46, requestKind=769}
 */
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
          imageNames: imageNames(for: activity),
          name: activity.name,
          rating: activity.rating, // ljw
          reviews: activity.reviews, // ljw
          somethingInteresting: activity.somethingInteresting,
          state: activity.state
        )
      )
    }
    return result
  }

  private func handleSource() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      for await message in await source.stream {
        print("ljw handleSource message \(Date()) \(#file):\(#function):\(#line)")
        print(message)
        switch message {
        case .error(let uiData):
          self.uiData = uiData
        case .loaded(let uiData):
          //self.uiData = uiData
          if uiData.activities.isEmpty {
            print("activities should not be zero should be \(self.uiData)")
            assertionFailure()
          }
          self.uiData = MoofuslistUIData(activities: self.uiData.activities, uiData: uiData)
          print("ljw loading=\(uiData.loading) \(Date()) \(#file):\(#function):\(#line)")
          print("ljw processing=\(uiData.processing) \(Date()) \(#file):\(#function):\(#line)")
          print("loaded activities count=\(self.uiData.activities.count)")
        case .loading(let activities, let uiData):
          print("before loading activities count=\(activities.count)")
          let activities = await convert(activities: activities, location: uiData.location)
          self.uiData = MoofuslistUIData(activities: activities, uiData: uiData)


//          self.uiData = uiData
//          print("before loading activities count=\(activities.count)")
//          self.uiData.activities = await convert(activities: activities, location: uiData.location)
          print("after loading activities count=\(self.uiData.activities.count)")
        case .processing(let uiData):
          print("ljw processing activities.count=\(uiData.activities.count) \(Date()) \(#file):\(#function):\(#line)")
          self.uiData = uiData
          if let mapItem = uiData.mapItem {
            let latitude = mapItem.location.coordinate.latitude
            let longitude = mapItem.location.coordinate.longitude
            let newCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let zoomOutDistance: CLLocationDistance = 5000 // meters, adjust as needed
            self.uiData.mapPosition = MapCameraPosition.camera(
              MapCamera(centerCoordinate: newCoordinate, distance: zoomOutDistance * 2) // doubling the distance to zoom out
            )
            if let cityState = mapItem.addressRepresentations?.cityWithContext {
              self.uiData.searchedCityState = cityState
            }
            withAnimation {
              self.uiData.mapItem = mapItem // TODO: test visually
            }
          }
        }
      }
    }
  }

  private func imageNames(for activity: AIManager.Activity) -> [String] {
    print("------------------------------")
    let activity = activity.lowercased()
    print(activity)

    var result = [String]()
    result = imageNames.process(input: activity.name, result: &result)
    result = imageNames.process(input: activity.category, result: &result)
    result = imageNames.process(input: activity.description, result: &result)
    result = removeSimilarImages(result: &result)

    if result.count < 1 {
      print(activity)
      assertionFailure()
      return ["mappin.circle.fill"]
    }
    return result
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
