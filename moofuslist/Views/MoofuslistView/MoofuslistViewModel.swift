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
class MoofuslistViewModel {
  struct Activity: Hashable, Identifiable {
    let id = UUID()
    let address: String
    let category: String
    let city: String
    let description: String
    let distance: Double
    let imageNames: [String]
//    let isFavorite = false
    let name: String
    let rating: Double
    let reviews: Int
    let somethingInteresting: String
    let state: String
  }

  @ObservationIgnored
  @Injected(\.moofuslistSource) var source: MoofuslistSource

  var activities = [Activity]()
  private var addressToLocationCache = [String: CLLocation]()
  private(set) var errorDescription = ""
  private(set) var errorRecoverySuggestion = ""
  var haveError = false
  private var imageNames = [String: [String]]()
  var inputError = false
  var isProcessing = false
  private(set) var loading = false
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "MoofuslistViewModel")
  private(set) var mapItem: MKMapItem?
  private(set) var searchedCityState = ""
  var selectedActivity: Activity?

  init() {
    buildImageNames()

    Task { await handleSource() }
  }
}

// MARK: - Private Methods
extension MoofuslistViewModel {
  private func buildImageNames() {
    imageNames["9/11 memorial"] = ["building.columns.fill"]
    imageNames["alcatraz"] = ["ferry.fill","binoculars.fill","figure.walk"]
    imageNames["arcade games"] = ["gamecontroller.fill"]
    imageNames["art"] = ["photo.artframe"]
    imageNames["art exhibits"] = ["paintpalette.fill"]
    imageNames["arts"] = ["photo.artframe"]
    imageNames["aquarium"] = ["fish.fill"]
    imageNames["aquariums"] = ["fish.fill"]
    imageNames["attractions"] = ["figure.walk"]
    imageNames["bakeries"] = ["birthday.cake"]
    imageNames["bars"] = ["wineglass.fill"]
    imageNames["beach"] = ["beach.umbrella.fill"]
    imageNames["beachs"] = ["beach.umbrella.fill"]
    imageNames["beauty salons"] = ["comb.fill"]
    imageNames["bike"] = ["bicycle"]
    imageNames["biking"] = ["bicycle"]
    imageNames["bridge"] = ["figure.walk"]
    imageNames["boat"] = ["ferry.fill"]
    imageNames["bookstores"] = ["books.vertical.fill"]
    imageNames["boutiques"] = ["handbag.fill"]
    imageNames["bowling"] = ["figure.bowling"]
    imageNames["brewery"] = ["cup.and.saucer.fill"]
    imageNames["butterfly exhibit"] = ["ant.fill", "ladybug.fill"]
    imageNames["cable car"] = ["cablecar.fill"]
    imageNames["cable cars"] = ["cablecar.fill"]
    imageNames["cafes"] = ["cup.and.saucer.fill"]
    imageNames["camping"] = ["tent.2.fill"]
    imageNames["children's activities"] = ["figure.child"]
    imageNames["chinatown"] = ["chineseyuanrenminbisign","fork.knife","storefront.fill"]
    imageNames["clubs"] = ["figure.socialdance","music.note.house.fill"]
    imageNames["coit tower"] = ["binoculars.fill"]
    imageNames["colleges"] = ["graduationcap.fill"]
    imageNames["comedy clubs"] = ["person.wave.2.fill"]
    imageNames["concert halls"] = ["music.note.house.fill"]
    imageNames["dance clubs"] = ["figure.socialdance"]
    imageNames["dining"] = ["fork.knife"]
    imageNames["district"] = ["storefront.fill"]
    imageNames["drive"] = ["car.fill"]
    imageNames["education"] = ["book.fill", "text.book.closed.fill"] // TODO: delete one
    imageNames["empire state building"] = ["building.columns.fill", "binoculars.fill"]
    imageNames["entertainment"] = ["popcorn.fill"]
    imageNames["events"] = ["calendar"]
    imageNames["ferry"] = ["ferry.fill"]
    imageNames["farmers markets"] = ["leaf.arrow.trianglehead.clockwise"]
    imageNames["fishing"] = ["figure.fishing"]
    imageNames["food"] = ["fork.knife"]
    imageNames["food trucks"] = ["truck.box.fill"]
    imageNames["galleries"] = ["photo.fill.on.rectangle.fill"]
    imageNames["garden"] = ["leaf.fill"]
    imageNames["gardens"] = ["leaf.fill"]
    imageNames["golf"] = ["figure.golf"]
    imageNames["graffiti"] = ["photo.artframe"]
    imageNames["gyms"] = ["dumbbell.fill"]
    imageNames["harbor"] = ["water.waves"]
    imageNames["haight-ashbury"] = ["figure.walk","binoculars.fill"]
    imageNames["health clinics"] = ["cross.fill"]
    imageNames["hike"] = ["figure.hiking"]
    imageNames["hiking"] = ["figure.hiking"]
    imageNames["historic site"] = ["building.columns.fill"]
    imageNames["historical"] = ["building.columns.fill"]
    imageNames["innovation"] = ["lightbulb.max.fill"]
    imageNames["insect exhibit"] = ["ant.fill", "ladybug.fill"]
    imageNames["karaoke"] = ["music.mic","music.note.house.fill"]
    imageNames["lakes"] = ["water.waves"]
    imageNames["landmark"] = ["building.columns.fill"]
    imageNames["landmarks"] = ["building.columns.fill"]
    imageNames["libraries"] = ["books.vertical.fill"]
    imageNames["little havana"] = ["storefront.fill","fork.knife" ]
    imageNames["lombard street"] = ["road.lanes.curved.right"]
    imageNames["lounges"] = ["sofa.fill"]
    imageNames["malls"] = ["building.2.fill"]
    imageNames["market"] = ["storefront.fill"]
    imageNames["massage"] = ["carseat.right.massage.fill"]
    imageNames["movies"] = ["movieclapper.fill","ticket.fill"]
    imageNames["murals"] = ["paintpalette.fill"]
    imageNames["museum"] = ["building.fill","figure.walk"]
    imageNames["museums"] = ["building.2.fill","figure.walk"]
    imageNames["music"] = ["music.pages.fill","music.note.house.fill"]
    imageNames["musicals"] = ["music.note.house.fill"]
    imageNames["nature"] = ["leaf.fill"]
    imageNames["nightlife"] = ["figure.socialdance","moon.stars"]
    imageNames["observatory"] = ["building.columns.fill"]
    imageNames["observe"] = ["binoculars.fill"]
    imageNames["outdoor"] = ["sun.max.fill"]
    imageNames["outdoor walk"] = ["sun.max.fill","figure.walk"]
    imageNames["park"] = ["tree.fill"]
    imageNames["parks"] = ["tree.fill"]
    imageNames["photography"] = ["camera.fill"]
    imageNames["pizza"] = ["fork.knife"]
    imageNames["pubs"] = ["mug.fill"]
    imageNames["playgrounds"] = ["figure.play"]
    imageNames["playgrounds"] = ["figure.play"]
    imageNames["racetrack"] = ["road.lanes.curved.right"]
    imageNames["restaurants"] = ["fork.knife"]
    imageNames["scenic views"] = ["binoculars.fill"]
    imageNames["scenic walk"] = ["binoculars.fill","figure.walk"]
    imageNames["schools"] = ["long.text.page.and.pencil"]
    imageNames["science"] = ["atom"]
    imageNames["shop"] = ["storefront.fill"]
    imageNames["shopping"] = ["storefront.fill","bag.fill"]
    imageNames["shops"] = ["storefront.fill"]
    imageNames["sightseeing"] = ["binoculars.fill"]
    imageNames["sightseeing walk"] = ["binoculars.fill","figure.walk"]
    imageNames["skateparks"] = ["skateboard.fill"]
    imageNames["space"] = ["moon.stars.fill","globe.americas.fill"]
    imageNames["sports"] = ["figure.basketball"]
    imageNames["stairs"] = ["figure.stairs"]
    imageNames["state capitol"] = ["building.columns.fill"]
    imageNames["statue of liberty"] = ["ferry.fill","figure.walk"]
    imageNames["stroll"] = ["figure.walk"]
    imageNames["swimming"] = ["figure.open.water.swim"]
    imageNames["tennis"] = ["figure.tennis","tennis.racket"]
    imageNames["theater"] = ["theatermasks.fill"]
    imageNames["theaters"] = ["theatermasks.fill"]
    imageNames["theatre"] = ["theatermasks.fill"]
    imageNames["theme parks"] = ["ticket.fill"]
    imageNames["times square"] = ["theatermasks.fill","storefront.fill","person.2.badge.plus.fill"]
    imageNames["tour"] = ["figure.walk"]
    imageNames["trails"] = ["figure.hiking"]
    imageNames["travel"] = ["airplane"]
    imageNames["university campus"] = ["graduationcap.fill","books.vertical.fill","building.2.fill"]
    imageNames["yoga"] = ["figure.yoga"]
    imageNames["vibrant boardwalk"] = ["fork.knife","storefront.fill"]
    imageNames["views"] = ["binoculars.fill"]
    imageNames["walking"] = ["figure.walk.motion"]
    imageNames["waterfront"] = ["water.waves"]
    imageNames["wharf"] = ["water.waves"]
    imageNames["wildlife"] = ["pawprint.fill"]
    imageNames["zoo"] = ["pawprint.fill"]
    imageNames["zoos"] = ["pawprint.fill"]
  }

  // Returns the coordinate of the most relevant result
  private func getDistance(from activity: AIManager.Activity) async throws -> Double {
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
      guard let coordinate = response.mapItems.first?.placemark.coordinate else {
        return activity.distance
      }
      activityLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      addressToLocationCache[activity.address] = activityLocation
    }
    let locationToSearch = await source.locationToSearch
    let meters = activityLocation.distance(from: locationToSearch)
    let distanceInMeters = Measurement(value: meters, unit: UnitLength.meters)
    let distanceInMiles = distanceInMeters.converted(to: UnitLength.miles)
    return distanceInMiles.value
  }

  private func convert(activities: [AIManager.Activity]) async -> [Activity] {
    var result = [Activity]()
    for activity in activities {
      let distance: Double
      do {
        distance = try await getDistance(from: activity)
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
          imageNames: imageNames(from: activity),
          name: activity.name,
          rating: 3.9,
          reviews: 45,
          somethingInteresting: activity.somethingInteresting,
          state: activity.state
        )
      )
    }
    return result
  }

  private func handleSource() async {
    for await message in source.stream {
      loading = false

      switch message {
      case .badInput:
        inputError = true
        isProcessing = false
      case .error(let error):
        if case let .location(description, recoverySuggestion) = error {
          errorDescription = description ?? "Error"
          errorRecoverySuggestion = recoverySuggestion ?? "Try again later."
        } else {
          // unknown error
          print("ljw \(Date()) \(#file):\(#function):\(#line)")
          errorDescription = error.localizedDescription
          errorRecoverySuggestion = ""
        }
        haveError = true
        isProcessing = false
      case .initial:
        print("ljw initial \(Date()) \(#file):\(#function):\(#line)")
        mapItem = nil
      case .loaded:
        print("ljw loaded \(Date()) \(#file):\(#function):\(#line)")
        mapItem = nil
        isProcessing = false
        print("loaded activities count=\(self.activities.count) \(activities.count)")

      case .loading(let mapItem, let activities):
        self.mapItem = mapItem
        if let cityState = mapItem?.addressRepresentations?.cityWithContext {
          searchedCityState = cityState
        }
        self.activities = await convert(activities: activities)
        withAnimation {
          loading = true
        }
      case .select(let activity):
        selectedActivity = activity
      }
    }
  }

  private func imageNames(from activity: AIManager.Activity) -> [String] {
    print("------------------------------")
    let activity = activity.lowercased()
    print(activity)

    var result = [String]()
    result = process(input: activity.name, result: &result)
    result = process(input: activity.category, result: &result)
    result = process(input: activity.description, result: &result)
    result = removeSimilarImages(result: &result)

    if result.count < 1 {
      print(activity)
      assertionFailure()
      return ["mappin.circle.fill"]
    }
    return result
  }

  private func process(input: String, result: inout [String]) -> [String] {
    for (key, imageStrings) in imageNames {
      if input.contains(key) {
        for imageString in imageStrings {
          if result.contains(imageString) { continue }
          result.append(imageString)
        }
      }
    }
    print("input=\(input) \(result)")
    return result
  }

  private func removeSimilarImages(result: inout [String]) -> [String] {
    if result.contains("building.columns.fill") {
      if let idx = result.firstIndex(of: "building.fill") {
        result.remove(at: idx)
      }
    }
    return result
  }
}
