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
  @Injected(\.locationManager) var locationManager: LocationManager

  init() {
    print("ljw \(Date()) \(#file):\(#function):\(#line)")
    Task {
      await handleLocationManager()
    }
  }

  private func handleLocationManager() async {
    for await location in locationManager.stream {
      print(location)
      // Reverse geocode with MapKit

      if let request = MKReverseGeocodingRequest(location: location) {
          do {
              let mapItems = try await request.mapItems
              print("items=")
            for item in mapItems {
              print(item)
              print("city=\(item.addressRepresentations?.cityName ?? "home")")
              print("cityWithContext=\(item.addressRepresentations?.cityWithContext)")
              print("regionName=\(item.addressRepresentations?.regionName)")
              print("region=\(item.addressRepresentations?.region)")
            }
            print("items end")
          } catch {
              print("Error reverse geocoding location: \(error)")
          }
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
