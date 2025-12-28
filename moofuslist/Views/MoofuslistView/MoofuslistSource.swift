//
//  MoofuslistSource.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/27/25.
//

import Foundation
import FactoryKit
import MapKit

final actor MoofuslistSource {
  struct Error {
    var errorDescription: String?
    var recoverySuggestion: String?
  }

  enum State {
    case initial
    case error(Error)
  }

  @Injected(\.locationManager) var locationManager: LocationManager

  private let continuation: AsyncStream<State>.Continuation
  let stream: AsyncStream<State>

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
    (stream, continuation) = AsyncStream.makeStream(of: State.self)
    Task {
      await handleLocationManager()
    }
  }
}

// MARK: - Private Methods
extension MoofuslistSource {
  private func handle(error: LocalizedError) async {
    let error = Error(
      errorDescription: error.errorDescription,
      recoverySuggestion: error.recoverySuggestion
    )
    continuation.yield(.error(error))
  }

  private func handle(location: CLLocation) async {
    if let request = MKReverseGeocodingRequest(location: location) {
      do {
        let mapItems = try await request.mapItems
        print("items=")
        for item in mapItems {
          print(item)
          print("city=\(item.addressRepresentations?.cityName ?? "home")")
          print("cityWithContext=\(item.addressRepresentations?.cityWithContext ?? "City, State")")
          print("regionName=\(item.addressRepresentations?.regionName ?? "Country")")
          print("region=\(item.addressRepresentations?.region ?? "Country")")
        }
        print("items end")
      } catch {
        print("Error reverse geocoding location: \(error)")
      }
    }
  }

  private func handleLocationManager() async {
    for await response in locationManager.stream {
      print(response) // ljw add warnings for print statements

      switch response {
      case .error(let error):
        await handle(error: error)
      case .location(let location):
        await handle(location: location)
      }
    }
  }
}

extension MoofuslistSource {
  func findActivities() async {
    print("starting")
    await locationManager.start()
    print("sleeping end")
  }
}
/*
 <MKMapItem: 0x116771f40> {
 address = "6825 Elverton Dr, Oakland, CA  94611, United States";
 isCurrentLocation = 0;
 name = "6825 Elverton Dr";
 placemark = "6825 Elverton Dr, 6825 Elverton Dr, Oakland, CA  94611, United States @ <+37.84662530,-122.20234210> +/- 0.00m, region CLCircularRegion (identifier:'<+37.84662530,-122.20234210> radius 70.59', center:<+37.84662530,-122.20234210>, radius:70.59m)";
 timeZone = "America/Los_Angeles (PST) offset -28800";
 }
 item.city=Oakland
 item.cityWithContext=Optional("Oakland, CA")
 item.regionName=Optional("United States")
 item.region=Optional(US)

 */
